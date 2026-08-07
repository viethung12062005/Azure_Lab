using './store.module.bicep'

param appsvc_outputs_azure_container_registry_endpoint = '{{ .Env.APPSVC_AZURE_CONTAINER_REGISTRY_ENDPOINT }}'
param appsvc_outputs_azure_container_registry_managed_identity_client_id = '{{ .Env.APPSVC_AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_CLIENT_ID }}'
param appsvc_outputs_azure_container_registry_managed_identity_id = '{{ .Env.APPSVC_AZURE_CONTAINER_REGISTRY_MANAGED_IDENTITY_ID }}'
param appsvc_outputs_planid = '{{ .Env.APPSVC_PLANID }}'
param store_containerimage = '{{ .Image }}'
param store_containerport = '{{ targetPortOrDefault 8080 }}'
