@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param appsvc_outputs_azure_container_registry_endpoint string

param appsvc_outputs_planid string

param appsvc_outputs_azure_container_registry_managed_identity_id string

param appsvc_outputs_azure_container_registry_managed_identity_client_id string

param store_containerimage string

param store_containerport string

resource mainContainer 'Microsoft.Web/sites/sitecontainers@2024-04-01' = {
  name: 'main'
  properties: {
    authType: 'UserAssigned'
    image: store_containerimage
    isMain: true
    userManagedIdentityClientId: appsvc_outputs_azure_container_registry_managed_identity_client_id
  }
  parent: webapp
}

resource webapp 'Microsoft.Web/sites@2024-04-01' = {
  name: take('${toLower('store')}-${uniqueString(resourceGroup().id)}', 60)
  location: location
  properties: {
    serverFarmId: appsvc_outputs_planid
    siteConfig: {
      linuxFxVersion: 'SITECONTAINERS'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: appsvc_outputs_azure_container_registry_managed_identity_client_id
      appSettings: [
        {
          name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EXCEPTION_LOG_ATTRIBUTES'
          value: 'true'
        }
        {
          name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EVENT_LOG_ATTRIBUTES'
          value: 'true'
        }
        {
          name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
          value: 'in_memory'
        }
        {
          name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
          value: 'true'
        }
        {
          name: 'HTTP_PORTS'
          value: store_containerport
        }
        {
          name: 'services__products__http__0'
          value: 'http://${take('${toLower('products')}-${uniqueString(resourceGroup().id)}', 60)}.azurewebsites.net'
        }
        {
          name: 'services__products__https__0'
          value: 'https://${take('${toLower('products')}-${uniqueString(resourceGroup().id)}', 60)}.azurewebsites.net'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appsvc_outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}