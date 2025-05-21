#!/bin/bash

# Azure deployment script for APIM with Private Endpoint Demo
# This script deploys the Azure resources using Bicep templates

# Set default values
SUBSCRIPTION_ID=""
RESOURCE_GROUP="apim-demo-rg"
LOCATION="eastus"
ENVIRONMENT="dev"
NAME_PREFIX="apim-demo"
ADMIN_EMAIL="admin@example.com"
ORG_NAME="APIM Demo Organization"
APIM_SKU="Developer"

# Display help information
function show_help {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s, --subscription    Azure Subscription ID (required)"
    echo "  -g, --resource-group  Resource Group name (default: $RESOURCE_GROUP)"
    echo "  -l, --location        Azure region (default: $LOCATION)"
    echo "  -e, --environment     Environment (dev, test, prod) (default: $ENVIRONMENT)"
    echo "  -p, --prefix          Name prefix for resources (default: $NAME_PREFIX)"
    echo "  -a, --admin-email     Admin email for APIM (default: $ADMIN_EMAIL)"
    echo "  -o, --org-name        Organization name for APIM (default: $ORG_NAME)"
    echo "  -k, --sku             APIM SKU (Developer, Basic, Standard, Premium) (default: $APIM_SKU)"
    echo "  -h, --help            Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--prefix)
            NAME_PREFIX="$2"
            shift 2
            ;;
        -a|--admin-email)
            ADMIN_EMAIL="$2"
            shift 2
            ;;
        -o|--org-name)
            ORG_NAME="$2"
            shift 2
            ;;
        -k|--sku)
            APIM_SKU="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Azure Subscription ID is required."
    show_help
    exit 1
fi

# Login to Azure
echo "Logging in to Azure..."
az login

# Set Azure subscription
echo "Setting Azure subscription..."
az account set --subscription $SUBSCRIPTION_ID

# Create Resource Group if it doesn't exist
echo "Creating Resource Group if it doesn't exist..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy Bicep template
echo "Deploying infrastructure..."
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters location=$LOCATION \
                 environment=$ENVIRONMENT \
                 namePrefix=$NAME_PREFIX \
                 apimAdminEmail=$ADMIN_EMAIL \
                 apimOrgName="$ORG_NAME" \
                 apimSku=$APIM_SKU

echo "Deployment completed!"
