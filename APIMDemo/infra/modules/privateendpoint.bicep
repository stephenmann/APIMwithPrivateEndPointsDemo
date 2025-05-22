@description('Location for all resources')
param location string

@description('Name of the Private Endpoint')
param privateEndpointName string

@description('Name of the Private DNS Zone')
param privateDnsZoneName string

@description('ID of the Virtual Network')
param vnetId string

@description('ID of the API Management service')
param apimId string

@description('ID of the subnet for the private endpoint')
param subnetId string

@description('ID of the subnet for the private link service')
param plsSubnetId string

// Private DNS Zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

// Link Private DNS Zone to VNET
resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Private Endpoint for APIM
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'apim-connection'
        properties: {
          privateLinkServiceId: apimId
          groupIds: [
            'gateway'
          ]
        }
      }
    ]
  }
}

// Standard Load Balancer for Private Link Service
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-05-01' = {
  name: '${privateEndpointName}-lb'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIpConfig'
        properties: {
          subnet: {
            id: plsSubnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', '${privateEndpointName}-lb', 'frontendIpConfig')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', '${privateEndpointName}-lb', 'backendPool')
          }
          protocol: 'Tcp'
          frontendPort: 443
          backendPort: 443
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', '${privateEndpointName}-lb', 'healthProbe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'healthProbe'
        properties: {
          protocol: 'Tcp'
          port: 443
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

// Private Link Service for Front Door
resource privateLinkService 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: '${privateEndpointName}-service'
  location: location
  properties: {
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', '${privateEndpointName}-lb', 'frontendIpConfig')
      }
    ]
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: plsSubnetId
          }
          primary: true
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    visibility: {
      subscriptions: []
    }
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoint
  name: 'dnszonegroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

// Outputs
output privateLinkServiceId string = privateLinkService.id
