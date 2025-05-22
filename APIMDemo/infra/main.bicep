@description('The location for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, test, prod)')
param environment string = 'dev'

@description('Name prefix for all resources')
param namePrefix string = 'apim-demo'

@description('Admin email for APIM notifications')
param apimAdminEmail string = 'admin@example.com'

@description('Organization name for APIM')
param apimOrgName string = 'APIM Demo Organization'

@description('APIM SKU')
@allowed(['Developer', 'Basic', 'Standard', 'Premium'])
param apimSku string = 'Developer'

// Variables
var uniqueNamePrefix = '${namePrefix}-${environment}'
var vnetName = '${uniqueNamePrefix}-vnet'
var apimName = '${uniqueNamePrefix}-apim'
var appServicePlanName = '${uniqueNamePrefix}-asp'
var appName = '${uniqueNamePrefix}-api'
var privateEndpointName = '${uniqueNamePrefix}-pe'
var appPrivateEndpointName = '${uniqueNamePrefix}-app-pe'
var privateDnsZoneName = '${namePrefix}-privatelink.azure-api.net'
var appPrivateDnsZoneName = 'privatelink.azurewebsites.net'
var apiBackendUrl = 'https://${appName}.azurewebsites.net'
var frontDoorName = '${uniqueNamePrefix}-fd'
var frontDoorEndpointName = '${namePrefix}${environment}'
var appInsightsName = '${uniqueNamePrefix}-ai'
var logAnalyticsWorkspaceName = '${uniqueNamePrefix}-law'

// Network resources
module networkModule 'modules/network.bicep' = {
  name: 'networkDeploy'
  params: {
    location: location
    vnetName: vnetName
    logAnalyticsWorkspaceId: appInsightsModule.outputs.logAnalyticsWorkspaceId
    enableDiagnostics: true
  }
}

// Application Insights resources
module appInsightsModule 'modules/appinsights.bicep' = {
  name: 'appInsightsDeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

// App Service resources
module appModule 'modules/appservice.bicep' = {
  name: 'appServiceDeploy'
  params: {
    location: location
    appName: appName
    appServicePlanName: appServicePlanName
    appInsightsConnectionString: appInsightsModule.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: appInsightsModule.outputs.appInsightsInstrumentationKey
    logAnalyticsWorkspaceId: appInsightsModule.outputs.logAnalyticsWorkspaceId
    enableDiagnostics: true
  }
}

// APIM resources
module apimModule 'modules/apim.bicep' = {
  name: 'apimDeploy'
  params: {
    location: location
    apimName: apimName
    apimSku: apimSku
    apimAdminEmail: apimAdminEmail
    apimOrgName: apimOrgName
    subnetId: networkModule.outputs.apimSubnetId
    apiBackendUrl: apiBackendUrl
    appInsightsId: appInsightsModule.outputs.appInsightsId
    appInsightsInstrumentationKey: appInsightsModule.outputs.appInsightsInstrumentationKey
  }
}

// Private endpoint resources for APIM
module privateEndpointModule 'modules/privateendpoint.bicep' = {
  name: 'privateEndpointDeploy'
  params: {
    location: location
    privateEndpointName: privateEndpointName
    privateDnsZoneName: privateDnsZoneName
    vnetId: networkModule.outputs.vnetId
    apimId: apimModule.outputs.apimId
    subnetId: networkModule.outputs.peSubnetId
    plsSubnetId: networkModule.outputs.plsSubnetId
  }
}

// Private endpoint for App Service
module appPrivateEndpointModule 'modules/appserviceprivateendpoint.bicep' = {
  name: 'appPrivateEndpointDeploy'
  params: {
    location: location
    privateEndpointName: appPrivateEndpointName
    privateDnsZoneName: appPrivateDnsZoneName
    vnetId: networkModule.outputs.vnetId
    appServiceId: appModule.outputs.apiId
    subnetId: networkModule.outputs.peSubnetId
  }
}

// Azure Front Door
module frontDoorModule 'modules/frontdoor.bicep' = {
  name: 'frontDoorDeploy'
  params: {
    location: location
    frontDoorName: frontDoorName
    endpointName: frontDoorEndpointName
    apimHostName: apimModule.outputs.apimHostName
    apimPrivateLinkServiceId: privateEndpointModule.outputs.privateLinkServiceId
    logAnalyticsWorkspaceId: appInsightsModule.outputs.logAnalyticsWorkspaceId
    enableDiagnostics: true
  }
}

// Output values
output apiUrl string = appModule.outputs.apiUrl
output apimUrl string = apimModule.outputs.apimUrl
output frontDoorUrl string = frontDoorModule.outputs.frontDoorEndpointUrl
