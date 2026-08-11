param(
    [Parameter(Mandatory = $true)]
    [string]$AppDisplayName,
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrg,
    [Parameter(Mandatory = $true)]
    [string]$GitHubRepo,
    [string]$SubscriptionId
)

# One-time setup: creates an Azure AD app registration + service principal with
# GitHub OIDC federated credentials (no client secret is ever created or stored).
# Requires: `az login` with a directory role that can create app registrations
# (e.g. Application Administrator) and a subscription role that can grant RBAC
# (e.g. Owner or User Access Administrator) on the target subscription.

$ErrorActionPreference = 'Stop'

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId | Out-Null
}

$subscriptionId = az account show --query id -o tsv
$tenantId = az account show --query tenantId -o tsv

Write-Host "Creating Azure AD app registration '$AppDisplayName'..."
$appId = az ad app create --display-name $AppDisplayName --query appId -o tsv

Write-Host "Creating service principal for app $appId..."
az ad sp create --id $appId | Out-Null

# GitHub's OIDC "sub" claim embeds the immutable numeric owner/repo IDs
# (repo:{owner}@{ownerId}/{repo}@{repoId}:...) so a federated credential
# written as plain "repo:owner/repo:..." silently stops matching and fails
# with AADSTS700213. Resolve the current IDs from the GitHub API so the
# credential always matches what GitHub actually issues.
Write-Host "Resolving GitHub owner/repo IDs for ${GitHubOrg}/${GitHubRepo}..."
$ownerId = (Invoke-RestMethod -Uri "https://api.github.com/users/$GitHubOrg" -Headers @{ 'User-Agent' = 'bootstrap-github-oidc' }).id
$repoId = (Invoke-RestMethod -Uri "https://api.github.com/repos/$GitHubOrg/$GitHubRepo" -Headers @{ 'User-Agent' = 'bootstrap-github-oidc' }).id
$repoSlug = "${GitHubOrg}@${ownerId}/${GitHubRepo}@${repoId}"
Write-Host "Resolved subject prefix: repo:$repoSlug"

# One federated credential per GitHub Environment (dev/uat/prod) so a token minted
# for one environment cannot be used to authenticate as another, plus one for
# plain pushes to main (used by the read-only CI plan job).
$subjects = @(
    "repo:${repoSlug}:environment:dev",
    "repo:${repoSlug}:environment:uat",
    "repo:${repoSlug}:environment:prod",
    "repo:${repoSlug}:ref:refs/heads/main"
)

foreach ($subject in $subjects) {
    $credName = ($subject -replace '[^a-zA-Z0-9]', '-')
    Write-Host "Creating federated credential for subject '$subject'..."

    $paramsFile = New-TemporaryFile
    @{
        name      = $credName
        issuer    = 'https://token.actions.githubusercontent.com'
        subject   = $subject
        audiences = @('api://AzureADTokenExchange')
    } | ConvertTo-Json -Compress | Set-Content -Path $paramsFile -Encoding utf8

    az ad app federated-credential create --id $appId --parameters "@$paramsFile" | Out-Null
    Remove-Item $paramsFile -Force
}

$scope = "/subscriptions/$subscriptionId"

# Contributor manages resources; Terraform also creates role assignments for the
# Products managed identity (Key Vault, Azure OpenAI, Storage), which requires a
# role-assignment-capable role in addition to Contributor.
Write-Host "Assigning 'Contributor' at $scope..."
az role assignment create --assignee $appId --role 'Contributor' --scope $scope | Out-Null

Write-Host "Assigning 'Role Based Access Control Administrator' at $scope..."
az role assignment create --assignee $appId --role 'Role Based Access Control Administrator' --scope $scope | Out-Null

Write-Host ''
Write-Host 'GitHub OIDC bootstrap completed.'
Write-Host ''
Write-Host 'Add these as repository-level Variables (Settings > Secrets and variables > Actions > Variables tab):'
Write-Host "  AZURE_CLIENT_ID       = $appId"
Write-Host "  AZURE_TENANT_ID       = $tenantId"
Write-Host "  AZURE_SUBSCRIPTION_ID = $subscriptionId"
Write-Host "  TF_STATE_RESOURCE_GROUP  = <resource group from bootstrap-terraform-state.ps1>"
Write-Host "  TF_STATE_STORAGE_ACCOUNT = <storage account from bootstrap-terraform-state.ps1>"
Write-Host ''
Write-Host 'Also create GitHub Environments named dev, uat, prod (Settings > Environments) and'
Write-Host 'add required reviewers on uat and prod so terraform apply pauses for approval.'
