param location string = resourceGroup().location
param vnetName string = 'myVNet'
param subnetName string = 'mySubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource lb 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: 'myInternalLB'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'myFrontend'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.0.10'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'myBackendPool'
      }
    ]
    probes: [
      {
        name: 'myHealthProbe'
        properties: {
          protocol: 'Tcp'
          port: 0
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'haPortRule'
        properties: {
          protocol: 'All'
          frontendPort: 0
          backendPort: 0
          frontendIPConfiguration: {
            id: lb.properties.frontendIPConfigurations[0].id
          }
          backendAddressPool: {
            id: lb.properties.backendAddressPools[0].id
          }
          probe: {
            id: lb.properties.probes[0].id
          }
          disableOutboundSnat: true
          enableTcpReset: true
          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}
