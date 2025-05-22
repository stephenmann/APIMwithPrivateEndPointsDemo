@description('Location for all resources')
param location string

@description('Name of the App Service')
param appName string

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Application Insights Connection String')
param appInsightsConnectionString string

@description('Application Insights Instrumentation Key')
param appInsightsInstrumentationKey string

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Enable diagnostic settings')
param enableDiagnostics bool = false

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: false
  }
}

// App Service
resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v7.0'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'default'
        }
        {
          name: 'InstrumentationEngine_EXTENSION_VERSION'
          value: '~1'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
      ]
    }
  }
}

// Output API URL
output apiUrl string = 'https://${app.properties.defaultHostName}'
output apiId string = app.id

// Diagnostic settings for App Service
module appServiceDiagnostics '../modules/diagnostics.bicep' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  name: '${appName}-diagnostics'
  params: {
    resourceId: app.id
    diagnosticSettingsName: '${appName}-diagnostics'
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    resourceType: 'appService'
  }
}
