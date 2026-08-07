@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

resource products_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: take('products_identity-${uniqueString(resourceGroup().id)}', 128)
  location: location
}

output id string = products_identity.id

output clientId string = products_identity.properties.clientId

output principalId string = products_identity.properties.principalId

output principalName string = products_identity.name