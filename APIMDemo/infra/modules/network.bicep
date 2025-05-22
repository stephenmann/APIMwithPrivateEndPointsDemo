@description('Location for all resources')
param location string

@description('Name of the Virtual Network')
param vnetName string

@description('Tags for all resources')
param tags object = {}

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Enable diagnostic settings')
param enableDiagnostics bool = false

// Variables
var addressPrefix = '10.0.0.0/16'
var peSubnetName = 'PrivateEndpointSubnet'
var peSubnetAddressPrefix = '10.0.0.0/24'
var apimSubnetName = 'ApimSubnet'
var apimSubnetAddressPrefix = '10.0.1.0/24'
var apiSubnetName = 'ApiSubnet'
var apiSubnetAddressPrefix = '10.0.2.0/24'
var plsSubnetName = 'PrivateLinkServiceSubnet'
var plsSubnetAddressPrefix = '10.0.3.0/24'

// Network Security Group for APIM subnet
resource apimNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${apimSubnetName}-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Management_Endpoint'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: peSubnetName
        properties: {
          addressPrefix: peSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: apimSubnetName
        properties: {
          addressPrefix: apimSubnetAddressPrefix
          networkSecurityGroup: {
            id: apimNsg.id
          }
        }
      }
      {
        name: apiSubnetName
        properties: {
          addressPrefix: apiSubnetAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: plsSubnetName
        properties: {
          addressPrefix: plsSubnetAddressPrefix
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// Outputs
output vnetId string = vnet.id
output peSubnetId string = vnet.properties.subnets[0].id
output apimSubnetId string = vnet.properties.subnets[1].id
output apiSubnetId string = vnet.properties.subnets[2].id
output plsSubnetId string = vnet.properties.subnets[3].id

// Diagnostic settings for VNet
module vnetDiagnostics '../modules/diagnostics.bicep' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  name: '${vnetName}-diagnostics'
  params: {
    resourceId: vnet.id
    diagnosticSettingsName: '${vnetName}-diagnostics'
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    resourceType: 'vnet'
  }
}

// Diagnostic settings for NSG
module nsgDiagnostics '../modules/diagnostics.bicep' = if (enableDiagnostics && !empty(logAnalyticsWorkspaceId)) {
  name: '${apimNsg.name}-diagnostics'
  params: {
    resourceId: apimNsg.id
    diagnosticSettingsName: '${apimNsg.name}-diagnostics'
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    resourceType: 'nsg'
  }
}
