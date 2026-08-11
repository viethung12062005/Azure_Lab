param(
    [string]$SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [string]$ContainerName = 'tfstate',
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [Parameter(Mandatory = $true)]
    [string]$Environment,
    [Parameter(Mandatory = $true)]
    [string]$Owner,
    [Parameter(Mandatory = $true)]
    [string]$CostCenter,
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    [string]$Criticality = 'high',
    [string]$DataClassification = 'confidential',
    [string]$ProjectName = 'eShopLite'
)

$ErrorActionPreference = 'Stop'

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId | Out-Null
}

$tags = @{
    Environment = $Environment
    Application = $ProjectName
    System = 'StoreProducts'
    Owner = $Owner
    ManagedBy = 'AzureCLI'
    Repository = $Repository
    CostCenter = $CostCenter
    Criticality = $Criticality
    DataClassification = $DataClassification
    BackupRequired = 'true'
    Region = $Location
    Workload = 'platform'
}

az group create `
    --name $ResourceGroupName `
    --location $Location `
    --tags ($tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) | Out-Null

az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --https-only true `
    --min-tls-version TLS1_2 `
    --allow-blob-public-access false `
    --tags ($tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) | Out-Null

az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login | Out-Null

$principalId = az ad signed-in-user show --query id -o tsv
$storageAccountId = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query id -o tsv

az role assignment create `
    --assignee-object-id $principalId `
    --assignee-principal-type User `
    --role 'Storage Blob Data Contributor' `
    --scope $storageAccountId | Out-Null

Write-Host ''
Write-Host 'Terraform state bootstrap completed.'
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "Storage Account: $StorageAccountName"
Write-Host "Container: $ContainerName"
Write-Host "Recommended backend key: $($Environment).terraform.tfstate"
