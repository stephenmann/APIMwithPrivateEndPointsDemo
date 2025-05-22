#!/bin/bash
# deploy-lite.sh - Lightweight deployment script without private networking
# Azure deployment script for APIM Demo (Lite version)
# This script deploys the Azure resources using Bicep templates without private networking

# Default parameters
SUBSCRIPTION_ID=""
RESOURCE_GROUP="apim-demo-lite-rg"
LOCATION="eastus"
ENVIRONMENT="dev"
NAME_PREFIX="apim-demo-lite"
ADMIN_EMAIL="admin@example.com"
ORG_NAME="APIM Demo Organization"
APIM_SKU="Developer"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --subscription)
      SUBSCRIPTION_ID="$2"
      shift 2
      ;;
    --resource-group)
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    --location)
      LOCATION="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --name-prefix)
      NAME_PREFIX="$2"
      shift 2
      ;;
    --admin-email)
      ADMIN_EMAIL="$2"
      shift 2
      ;;
    --org-name)
      ORG_NAME="$2"
      shift 2
      ;;
    --apim-sku)
      APIM_SKU="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Verify subscription ID is provided
if [ -z "$SUBSCRIPTION_ID" ]; then
  echo "Error: Subscription ID is required"
  echo "Usage: ./deploy-lite.sh --subscription <subscription-id> [--resource-group <resource-group>] [--location <location>] [--environment <environment>] [--name-prefix <name-prefix>] [--admin-email <admin-email>] [--org-name <org-name>] [--apim-sku <apim-sku>]"
  exit 1
fi

# Login to Azure
echo "Logging in to Azure..."
az login

# Set Azure subscription
echo "Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create Resource Group if it doesn't exist
echo "Creating Resource Group if it doesn't exist..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Deploy Bicep template (using the lite version)
echo "Deploying lite infrastructure..."
DEPLOYMENT_NAME="apim-lite-deployment-$(date +%Y%m%d%H%M%S)"
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DEPLOYMENT_NAME" \
    --template-file main-lite.bicep \
    --parameters location="$LOCATION" \
                 environment="$ENVIRONMENT" \
                 namePrefix="$NAME_PREFIX" \
                 apimAdminEmail="$ADMIN_EMAIL" \
                 apimOrgName="$ORG_NAME" \
                 apimSku="$APIM_SKU"

# Capture outputs from the deployment
echo "Retrieving deployment outputs..."
APP_SERVICE_NAME="${NAME_PREFIX}-${ENVIRONMENT}-api"

# Ensure App Service is ready
echo "Waiting for App Service to be ready..."
RETRY_COUNT=0
MAX_RETRIES=10
READY=false

while [ "$READY" != "true" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    
    APP_SERVICE_STATUS=$(az webapp show --name "$APP_SERVICE_NAME" --resource-group "$RESOURCE_GROUP" --query state -o tsv 2>/dev/null)
    
    if [ "$APP_SERVICE_STATUS" = "Running" ]; then
        READY=true
        echo "App Service is ready!"
    else
        echo "App Service is not ready yet. Status: $APP_SERVICE_STATUS. Waiting 15 seconds... (Attempt $RETRY_COUNT of $MAX_RETRIES)"
        sleep 15
    fi
done

if [ "$READY" != "true" ]; then
    echo "Warning: App Service did not reach ready state after $MAX_RETRIES attempts. Continuing with deployment anyway..."
fi

echo "Preparing API application for deployment..."

# Navigate to the API project directory
CURRENT_PATH=$(pwd)
PROJECT_PATH=$(dirname "$CURRENT_PATH")
PROJECT_FILE="$PROJECT_PATH/APIMDemo.csproj"

# Verify project exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: Could not find the API project file at $PROJECT_FILE"
    exit 1
fi

# Publish the application
echo "Publishing .NET application..."
dotnet publish "$PROJECT_FILE" -c Release -o "$PROJECT_PATH/publish"
if [ $? -ne 0 ]; then
    echo "Error: Failed to publish the application"
    exit 1
fi

# Create a zip file of the published content
echo "Creating deployment package..."
PUBLISH_FOLDER="$PROJECT_PATH/publish"
PUBLISH_ZIP_PATH="$PROJECT_PATH/publish.zip"

if [ ! -d "$PUBLISH_FOLDER" ]; then
    echo "Error: Publish folder does not exist at $PUBLISH_FOLDER"
    exit 1
fi

if [ -f "$PUBLISH_ZIP_PATH" ]; then
    rm "$PUBLISH_ZIP_PATH"
fi

if command -v zip &> /dev/null; then
    (cd "$PUBLISH_FOLDER" && zip -r "$PUBLISH_ZIP_PATH" .)
else
    echo "Error: 'zip' command not found. Please install zip or use PowerShell for deployment."
    exit 1
fi

# Deploy to Azure App Service
echo "Deploying to App Service: $APP_SERVICE_NAME"
az webapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --src "$PUBLISH_ZIP_PATH"

if [ $? -ne 0 ]; then
    echo "Error: Failed to deploy to App Service"
    exit 1
fi

# Display deployment information
echo -e "\nDeployment completed successfully!"
echo -e "\nResource Group: $RESOURCE_GROUP"

# Get the URLs for API and APIM
API_URL="https://$APP_SERVICE_NAME.azurewebsites.net"
APIM_URL=$(az apim show --name "${NAME_PREFIX}-${ENVIRONMENT}-apim" --resource-group "$RESOURCE_GROUP" --query "gatewayUrl" -o tsv)

echo -e "\nEndpoints:"
echo "- API URL: $API_URL"
echo "- APIM URL: https://$APIM_URL"
echo -e "\nNote: This is a lite deployment without private networking."

echo -e "\nLite deployment completed!"
