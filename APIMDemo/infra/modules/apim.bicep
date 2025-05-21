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
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
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
    value: loadTextContent('../api-definitions/api-v1.json')
    serviceUrl: '${apiBackendUrl}/api/v1'
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
    value: loadTextContent('../api-definitions/api-v2.json')
    serviceUrl: '${apiBackendUrl}/api/v2'
  }
}

// Associate products with APIs
resource productApiV1 'Microsoft.ApiManagement/service/products/apis@2023-03-01-preview' = {
  parent: apiProduct
  name: apiV1.name
}

resource productApiV2 'Microsoft.ApiManagement/service/products/apis@2023-03-01-preview' = {
  parent: apiProduct
  name: apiV2.name
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
