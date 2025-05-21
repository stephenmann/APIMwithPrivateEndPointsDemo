# GitHub Actions Deployment Guide

This guide explains how to set up and use the GitHub Actions workflow for deploying the Azure API Management with Private Endpoints infrastructure.

## Prerequisites

1. An Azure subscription
2. GitHub repository with this code
3. Permissions to create service principals in Azure

## Setting up Azure Credentials

To deploy to Azure using GitHub Actions, you need to create a service principal and add it as a secret in your GitHub repository.

### Creating a Service Principal

1. Install the Azure CLI on your local machine if you haven't already
2. Login to Azure:
   ```bash
   az login
   ```
3. Create a service principal with contributor rights to your subscription:
   ```bash
   az ad sp create-for-rbac --name "GitHubActionsAPIM" --role contributor \
                             --scopes /subscriptions/{subscription-id} \
                             --sdk-auth
   ```
   Replace `{subscription-id}` with your Azure subscription ID.

4. The command will output a JSON object like this:
   ```json
   {
     "clientId": "<GUID>",
     "clientSecret": "<SECRET>",
     "subscriptionId": "<GUID>",
     "tenantId": "<GUID>",
     "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
     "resourceManagerEndpointUrl": "https://management.azure.com/",
     "activeDirectoryGraphResourceId": "https://graph.windows.net/",
     "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
     "galleryEndpointUrl": "https://gallery.azure.com/",
     "managementEndpointUrl": "https://management.core.windows.net/"
   }
   ```

### Adding the Secret to GitHub

1. In your GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**
2. Click on **New repository secret**
3. Name the secret `AZURE_CREDENTIALS`
4. Paste the entire JSON output from the service principal creation step
5. Click **Add secret**

## Running the Workflow

1. In your GitHub repository, navigate to the **Actions** tab
2. Select the **Deploy APIM Infrastructure** workflow
3. Click **Run workflow**
4. A form will appear with the following fields:
   - **Azure Subscription ID**: Your Azure subscription ID
   - **Resource Group**: The resource group to deploy to (default: apim-demo-rg)
   - **Location**: Azure region for deployment (default: eastus)
   - **Environment**: The environment to deploy (dev, test, prod) (default: dev)
   - **Name Prefix**: Prefix for resource names (default: apim-demo)
   - **Admin Email**: Email for APIM notifications (default: admin@example.com)
   - **Organization Name**: Organization name for APIM (default: APIM Demo Organization)
   - **APIM SKU**: SKU for API Management (Developer, Basic, Standard, Premium) (default: Developer)
5. Fill in the required values and click **Run workflow**

The workflow will:
1. Check out your code
2. Set up the Azure CLI
3. Authenticate with Azure using your credentials
4. Create the resource group if it doesn't exist
5. Deploy the Bicep template with the parameters you provided

## Troubleshooting

- If the workflow fails with authentication errors, ensure your service principal has the correct permissions and that the secret is properly configured
- For deployment errors, check the workflow logs for specific Azure error messages
- If you need to update the service principal, generate a new one and update the GitHub secret