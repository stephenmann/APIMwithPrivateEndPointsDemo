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
var privateDnsZoneName = '${namePrefix}-privatelink.azure-api.net'
var apiBackendUrl = 'https://${appName}.azurewebsites.net'

// Network resources
module networkModule 'modules/network.bicep' = {
  name: 'networkDeploy'
  params: {
    location: location
    vnetName: vnetName
  }
}

// App Service resources
module appModule 'modules/appservice.bicep' = {
  name: 'appServiceDeploy'
  params: {
    location: location
    appName: appName
    appServicePlanName: appServicePlanName
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
  }
  dependsOn: [
    networkModule
  ]
}

// Private endpoint resources
module privateEndpointModule 'modules/privateendpoint.bicep' = {
  name: 'privateEndpointDeploy'
  params: {
    location: location
    privateEndpointName: privateEndpointName
    privateDnsZoneName: privateDnsZoneName
    vnetId: networkModule.outputs.vnetId
    apimId: apimModule.outputs.apimId
    subnetId: networkModule.outputs.peSubnetId
  }
  dependsOn: [
    apimModule
  ]
}

// Output values
output apiUrl string = appModule.outputs.apiUrl
output apimUrl string = apimModule.outputs.apimUrl
