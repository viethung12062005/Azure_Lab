@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param userPrincipalId string

param tags object = { }

resource appsvc_mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: take('appsvc_mi-${uniqueString(resourceGroup().id)}', 128)
  location: location
  tags: tags
}

resource appsvc_acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: take('appsvcacr${uniqueString(resourceGroup().id)}', 50)
  location: location
  sku: {
    name: 'Basic'
  }
  tags: tags
}

resource appsvc_acr_appsvc_mi_AcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appsvc_acr.id, appsvc_mi.id, subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d'))
  properties: {
    principalId: appsvc_mi.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
  scope: appsvc_acr
}

resource appsvc_asplan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: take('appsvcasplan-${uniqueString(resourceGroup().id)}', 60)
  location: location
  properties: {
    reserved: true
  }
  kind: 'Linux'
  sku: {
    name: 'P0V3'
    tier: 'Premium'
  }
}

output planId string = appsvc_asplan.id

output AZURE_CONTAINER_REGISTRY_NAME string = appsvc_acr.name

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = appsvc_acr.properties.loginServer

output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID string = appsvc_mi.id

output AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_CLIENT_ID string = appsvc_mi.properties.clientId