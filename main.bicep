
@description('The type of environment. This must be nonprod or prod.')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@description('Indicates whether to deploy the storage account for toy manuals.')
param deployToyManualsStorageAccount bool

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)


param storageAccounts_xlrepo_name string = 'xlrepo'

@description('The Azure region into which the resources should be deployed.')
param deploymentRegion string = resourceGroup().location
@description('the keyvault')
param vaults_pankeyvisa_name string = 'pankeyvisa'
@description('the Tier for Storage')
param tier string = 'Standard'

resource storageAccounts_xlrepo_name_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccounts_xlrepo_name
  location: deploymentRegion
  sku: {
    name: 'Standard_LRS'
    tier: tier
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: false
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccounts_xlrepo_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  parent: storageAccounts_xlrepo_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: tier
  }
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_xlrepo_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  parent: storageAccounts_xlrepo_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: tier
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_xlrepo_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = {
  parent: storageAccounts_xlrepo_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_xlrepo_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-08-01' = {
  parent: storageAccounts_xlrepo_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource storageAccounts_xlrepo_name_default_pan 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  parent: storageAccounts_xlrepo_name_default
  name: 'pan'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
    immutableStorageWithVersioning: {
      enabled: false
    }
  }
  dependsOn: [

  ]
}

resource vaults_pankeyvisa_name_resource 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaults_pankeyvisa_name
  location: deploymentRegion
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'c3d948db-a88c-4f1c-8123-e9d6b76e8747'
    accessPolicies: [
      {
        tenantId: 'c3d948db-a88c-4f1c-8123-e9d6b76e8747'
        objectId: 'd122a565-e399-4114-b9bc-0ef17e1c7a74'
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
#disable-next-line no-hardcoded-env-urls
    vaultUri: 'https://${vaults_pankeyvisa_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}
