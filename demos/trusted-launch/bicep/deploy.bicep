targetScope = 'resourceGroup'

@description('Required. Name of the Virtual Machine.')
param vmName string

@description('Required. Location of the Virtual Machine.')
param location string = resourceGroup().location

@description('Required. Admin username of the Virtual Machine.')
param adminUsername string

@description('Required. Password or ssh key for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

@description('Optional. Size of the VM.')
param vmSize string = 'Standard_D2s_v5'

@description('Optional. OS Image for the Virtual Machine')
@allowed([
  'Windows Server 2022 Gen 2'
  'Windows Server 2019 Gen 2'
  'Ubuntu 20.04 LTS Gen 2'
])
param osImageName string = 'Ubuntu 20.04 LTS Gen 2'

@description('Optional. OS disk type of the Virtual Machine.')
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('Optional. Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Optional. Enable boot diagnostics setting of the Virtual Machine.')
@allowed([
  true
  false
])
param bootDiagnostics bool = false

@description('MAA Endpoint to attest to.')
@allowed([
  'https://sharedcus.cus.attest.azure.net/'
  'https://sharedcae.cae.attest.azure.net/'
  'https://sharedeus2.eus2.attest.azure.net/'
  'https://shareduks.uks.attest.azure.net/'
  'https://sharedcac.cac.attest.azure.net/'
  'https://sharedukw.ukw.attest.azure.net/'
  'https://sharedneu.neu.attest.azure.net/'
  'https://sharedeus.eus.attest.azure.net/'
  'https://sharedeau.eau.attest.azure.net/'
  'https://sharedncus.ncus.attest.azure.net/'
  'https://sharedwus.wus.attest.azure.net/'
  'https://sharedweu.weu.attest.azure.net/'
  'https://sharedscus.scus.attest.azure.net/'
  'https://sharedsasia.sasia.attest.azure.net/'
  'https://sharedsau.sau.attest.azure.net/'
])
param maaEndpoint string = 'https://sharedeus2.eus2.attest.azure.net/'

@description('Secure Boot setting of the virtual machine.')
param secureBoot bool = true

@description('vTPM setting of the virtual machine.')
param vTPM bool = true


var imageList = {
  'Windows Server 2022 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2022-datacenter-smalldisk-g2'
    version: 'latest'
  }
  'Windows Server 2019 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2019-datacenter-smalldisk-g2'
    version: 'latest'
  }
  'Ubuntu 20.04 LTS Gen 2': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-focal'
    sku: '20_04-lts-gen2'
    version: 'latest'
  }
}

var isWindows = contains(osImageName, 'Windows')

var cloudInitData = loadFileAsBase64('assets/cloudinit.yml')

var ascReportingEndpoint = maaEndpoint
var disableAlerts = 'false'
var extensionName = 'GuestAttestation'
var extensionPublisher = isWindows ? 'Microsoft.Azure.Security.WindowsAttestation' : 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var useAlternateToken = 'false'

var virtualNetworkName = '${vmName}-vnet'
var subnetName = '${vmName}-vnet-sn'
var subnetResourceId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: '${vmName}-ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: (isWindows ? 'RDP' : 'SSH')
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: (isWindows ? '3389' : '22')
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetResourceId
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
  dependsOn:[
    virtualNetwork
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bootDiagnostics
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: imageList[osImageName]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPasswordOrKey
      customData:  !isWindows ? cloudInitData : json('null')
      linuxConfiguration: ((authenticationType == 'password') ? json('null') : {
        disablePasswordAuthentication: 'true'
        ssh: {
          publicKeys: [
            {
              keyData: adminPasswordOrKey
              path: '/home/${adminUsername}/.ssh/authorized_keys'
            }
          ]
        }
      })
      windowsConfiguration: (!isWindows ? json('null') : {
        enableAutomaticUpdates: 'true'
        provisionVmAgent: 'true'
      })
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
      securityType: 'TrustedLaunch'
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (vTPM && secureBoot) {
  parent: vm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      AttestationEndpointCfg: {
        maaEndpoint: maaEndpoint
        maaTenantName: maaTenantName
        ascReportingEndpoint: ascReportingEndpoint
        useAlternateToken: useAlternateToken
        disableAlerts: disableAlerts
      }
    }
  }
}
