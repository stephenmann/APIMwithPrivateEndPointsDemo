// main-lite.bicep - Lightweight deployment without private endpoints
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
var apimName = '${uniqueNamePrefix}-apim'
var appServicePlanName = '${uniqueNamePrefix}-asp'
var appName = '${uniqueNamePrefix}-api'
var apiBackendUrl = 'https://${appName}.azurewebsites.net'
var appInsightsName = '${uniqueNamePrefix}-ai'
var logAnalyticsWorkspaceName = '${uniqueNamePrefix}-law'

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

// Modified APIM module without virtual network integration
module apimLiteModule 'modules/apim-lite.bicep' = {
  name: 'apimLiteDeploy'
  params: {
    location: location
    apimName: apimName
    apimSku: apimSku
    apimAdminEmail: apimAdminEmail
    apimOrgName: apimOrgName
    apiBackendUrl: apiBackendUrl
    appInsightsId: appInsightsModule.outputs.appInsightsId
    appInsightsInstrumentationKey: appInsightsModule.outputs.appInsightsInstrumentationKey
  }
}

// Output values
output apiUrl string = appModule.outputs.apiUrl
output apimUrl string = apimLiteModule.outputs.apimUrl
