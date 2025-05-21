@description('Location for all resources')
param location string

@description('Name of the Virtual Network')
param vnetName string

// Variables
var addressPrefix = '10.0.0.0/16'
var peSubnetName = 'PrivateEndpointSubnet'
var peSubnetAddressPrefix = '10.0.0.0/24'
var apimSubnetName = 'ApimSubnet'
var apimSubnetAddressPrefix = '10.0.1.0/24'
var apiSubnetName = 'ApiSubnet'
var apiSubnetAddressPrefix = '10.0.2.0/24'

// Network Security Group for APIM subnet
resource apimNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${apimSubnetName}-nsg'
  location: location
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
    ]
  }
}

// Outputs
output vnetId string = vnet.id
output peSubnetId string = vnet.properties.subnets[0].id
output apimSubnetId string = vnet.properties.subnets[1].id
output apiSubnetId string = vnet.properties.subnets[2].id
