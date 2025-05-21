# Azure deployment script for APIM with Private Endpoint Demo
# This script deploys the Azure resources using Bicep templates

# Default parameters
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "apim-demo-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$NamePrefix = "apim-demo",
    
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

# Deploy Bicep template
Write-Host "Deploying infrastructure..." -ForegroundColor Cyan
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file main.bicep `
    --parameters location=$Location `
                 environment=$Environment `
                 namePrefix=$NamePrefix `
                 apimAdminEmail=$AdminEmail `
                 apimOrgName="$OrgName" `
                 apimSku=$ApimSku

Write-Host "Deployment completed!" -ForegroundColor Green
