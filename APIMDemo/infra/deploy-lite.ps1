# deploy-lite.ps1 - Lightweight deployment script without private networking
# Azure deployment script for APIM Demo (Lite version)
# This script deploys the Azure resources using Bicep templates without private networking

# Default parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "apim-demo-lite-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$NamePrefix = "apim-demo-lite",
    
    [Parameter(Mandatory=$false)]
    [string]$AdminEmail = "admin@example.com",
    
    [Parameter(Mandatory=$false)]
    [string]$OrgName = "APIM Demo Organization",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Developer", "Basic", "Standard", "Premium")]
    [string]$ApimSku = "Developer"
)

# Login to Azure
Write-Host "Logging in to Azure..." -ForegroundColor Cyan
az login

# Set Azure subscription
Write-Host "Setting Azure subscription..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId

# Create Resource Group if it doesn't exist
Write-Host "Creating Resource Group if it doesn't exist..." -ForegroundColor Cyan
az group create --name $ResourceGroup --location $Location

# Deploy Bicep template (using the lite version)
Write-Host "Deploying lite infrastructure..." -ForegroundColor Cyan
$deploymentName = "apim-lite-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
az deployment group create `
    --resource-group $ResourceGroup `
    --name $deploymentName `
    --template-file main-lite.bicep `
    --parameters location=$Location `
                 environment=$Environment `
                 namePrefix=$NamePrefix `
                 apimAdminEmail=$AdminEmail `
                 apimOrgName="$OrgName" `
                 apimSku=$ApimSku

# Capture outputs from the deployment
Write-Host "Retrieving deployment outputs..." -ForegroundColor Cyan
$deploymentOutput = az deployment group show --resource-group $ResourceGroup --name $deploymentName --query properties.outputs -o json | ConvertFrom-Json
$appServiceName = "${NamePrefix}-${Environment}-api"

# Ensure App Service is ready
Write-Host "Waiting for App Service to be ready..." -ForegroundColor Cyan
$retryCount = 0
$maxRetries = 10
$ready = $false

do {
    $retryCount++
    try {
        $appServiceStatus = az webapp show --name $appServiceName --resource-group $ResourceGroup --query state -o tsv
        if ($appServiceStatus -eq "Running") {
            $ready = $true
            Write-Host "App Service is ready!" -ForegroundColor Green
        } else {
            Write-Host "App Service is not ready yet. Status: $appServiceStatus. Waiting 15 seconds... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds 15
        }
    } catch {
        Write-Host "Error checking App Service status. Waiting 15 seconds... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
        Start-Sleep -Seconds 15
    }
} while (-not $ready -and $retryCount -lt $maxRetries)

if (-not $ready) {
    Write-Warning "App Service did not reach ready state after $maxRetries attempts. Continuing with deployment anyway..."
}

Write-Host "Preparing API application for deployment..." -ForegroundColor Cyan

# Navigate to the API project directory
$currentPath = Get-Location
$projectFile = Join-Path -Path (Split-Path -Parent $currentPath) -ChildPath "APIMDemo.csproj"

# Verify project exists
if (-not (Test-Path $projectFile)) {
    Write-Error "Could not find the API project file at $projectFile"
    exit 1
}

# Publish the application
Write-Host "Publishing .NET application..." -ForegroundColor Cyan
$projectPath = Split-Path -Parent $currentPath
try {
    dotnet publish $projectFile -c Release -o "$projectPath/publish"
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "Failed to publish the application: $_"
    exit 1
}

# Create a zip file of the published content
Write-Host "Creating deployment package..." -ForegroundColor Cyan
$publishFolder = "$projectPath/publish"
$publishZipPath = "$projectPath/publish.zip"

if (-not (Test-Path $publishFolder)) {
    Write-Error "Publish folder does not exist at $publishFolder"
    exit 1
}

if (Test-Path $publishZipPath) { Remove-Item $publishZipPath -Force }

try {
    Compress-Archive -Path "$publishFolder/*" -DestinationPath $publishZipPath
} catch {
    Write-Error "Failed to create deployment package: $_"
    exit 1
}

# Deploy to Azure App Service
Write-Host "Deploying to App Service: $appServiceName" -ForegroundColor Cyan
try {
    az webapp deployment source config-zip `
        --resource-group $ResourceGroup `
        --name $appServiceName `
        --src $publishZipPath
    
    if ($LASTEXITCODE -ne 0) {
        throw "Deployment to App Service failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "Failed to deploy to App Service: $_"
    exit 1
}

# Display deployment information
Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
Write-Host "`nResource Group: $ResourceGroup" -ForegroundColor Cyan

# Get the URLs for API and APIM
try {
    $apiUrl = "https://$appServiceName.azurewebsites.net"
    $apimUrl = az apim show --name "${NamePrefix}-${Environment}-apim" --resource-group $ResourceGroup --query "gatewayUrl" -o tsv

    Write-Host "`nEndpoints:" -ForegroundColor Cyan
    Write-Host "- API URL: $apiUrl" -ForegroundColor Yellow
    Write-Host "- APIM URL: https://$apimUrl" -ForegroundColor Yellow
    Write-Host "`nNote: This is a lite deployment without private networking." -ForegroundColor Yellow
} catch {
    Write-Warning "Could not retrieve all endpoint information. Please check the Azure portal for details."
}

Write-Host "`nLite deployment completed!" -ForegroundColor Green
