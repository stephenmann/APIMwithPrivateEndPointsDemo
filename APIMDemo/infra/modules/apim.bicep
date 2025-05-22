@description('Location for all resources')
param location string

@description('Name of the API Management service')
param apimName string

@description('SKU of the API Management service')
param apimSku string

@description('Admin email address')
param apimAdminEmail string

@description('Organization name')
param apimOrgName string

@description('The subnet ID for APIM')
param subnetId string

@description('The backend API URL')
param apiBackendUrl string

@description('Application Insights Instrumentation Key')
param appInsightsInstrumentationKey string = ''

@description('Application Insights Resource ID')
param appInsightsId string = ''

// API Management Service
resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: apimSku
    capacity: 1
  }
  properties: {
    publisherEmail: apimAdminEmail
    publisherName: apimOrgName
    virtualNetworkType: 'External'
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
  }
}

// Application Insights logger for APIM
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = if (!empty(appInsightsId) && !empty(appInsightsInstrumentationKey)) {
  parent: apim
  name: 'appInsightsLogger'
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
    resourceId: appInsightsId
    isBuffered: true
  }
}

// Create API Version Set
resource apiVersionSet 'Microsoft.ApiManagement/service/apiVersionSets@2023-03-01-preview' = {
  parent: apim
  name: 'demo-api-versions'
  properties: {
    displayName: 'Demo API Versions'
    versioningScheme: 'Segment'
    description: 'Version set for the Demo API'
  }
}

// Product for API
resource apiProduct 'Microsoft.ApiManagement/service/products@2023-03-01-preview' = {
  parent: apim
  name: 'Demo-API'
  properties: {
    displayName: 'Demo API Product'
    description: 'This is a sample API product for demonstration purposes'
    subscriptionRequired: true
    approvalRequired: false
    state: 'published'
  }
}

// API V1
resource apiV1 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'demo-api-v1'
  properties: {
    displayName: 'Demo API v1'
    apiRevision: '1'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    path: 'v1'
    format: 'openapi+json'
    value: loadTextContent('../api-definitions/api-v1-modified.json')
    serviceUrl: '${apiBackendUrl}/api/v1'
    apiVersion: 'v1'
    apiVersionSetId: apiVersionSet.id
  }
}

// API V2
resource apiV2 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'demo-api-v2'
  properties: {
    displayName: 'Demo API v2'
    apiRevision: '1'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    path: 'v2'
    format: 'openapi+json'
    value: loadTextContent('../api-definitions/api-v2-modified.json')
    serviceUrl: '${apiBackendUrl}/api/v2'
    apiVersion: 'v2'
    apiVersionSetId: apiVersionSet.id
  }
}

// Associate products with APIs - do this for each API separately
resource productApiV1 'Microsoft.ApiManagement/service/products/apis@2023-03-01-preview' = {
  parent: apiProduct
  name: apiV1.name
}

resource productApiV2 'Microsoft.ApiManagement/service/products/apis@2023-03-01-preview' = {
  parent: apiProduct
  name: apiV2.name
}

// Diagnostic setting for API V1
resource apiV1Diagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2023-03-01-preview' = if (!empty(appInsightsId) && !empty(appInsightsInstrumentationKey)) {
  parent: apiV1
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'W3C'
    logClientIp: true
    loggerId: apimLogger.id
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
    verbosity: 'information'
    metrics: true
  }
}

// Diagnostic setting for API V2
resource apiV2Diagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2023-03-01-preview' = if (!empty(appInsightsId) && !empty(appInsightsInstrumentationKey)) {
  parent: apiV2
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'W3C'
    logClientIp: true
    loggerId: apimLogger.id
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
    verbosity: 'information'
    metrics: true
  }
}

// Subscription for testing
resource subscription 'Microsoft.ApiManagement/service/subscriptions@2023-03-01-preview' = {
  parent: apim
  name: 'demo-subscription'
  properties: {
    scope: apiProduct.id
    displayName: 'Demo Subscription'
    state: 'active'
  }
}

// Outputs
output apimId string = apim.id
output apimUrl string = 'https://${apim.properties.gatewayUrl}'
output apimHostName string = apim.properties.gatewayUrl
