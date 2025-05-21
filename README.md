# Azure API Management with Private Endpoints Demo

This project demonstrates the use of Azure API Management (APIM) with private endpoints, featuring a sample API application with multiple endpoints and API versions.

## Features

- .NET Core Web API with versioned API endpoints (v1 and v2)
- Complete Bicep templates for Azure infrastructure deployment
- Private endpoint integration for secure access to APIM
- Multiple API versions to demonstrate APIM versioning capabilities
- Sample services for Products and Orders domains

## Project Structure

```
APIMDemo/
├── Controllers/
│   ├── v1/                   # Version 1 API controllers
│   │   ├── ProductsController.cs
│   │   └── OrdersController.cs
│   └── v2/                   # Version 2 API controllers
│       ├── ProductsController.cs
│       └── OrdersController.cs
├── Models/                   # Domain models for the API
│   ├── Product.cs
│   └── Order.cs
├── Interfaces/               # Service interfaces
│   ├── IProductService.cs
│   └── IOrderService.cs
├── Services/                 # Service implementations
│   ├── ProductService.cs
│   ├── ProductServiceV2.cs
│   ├── OrderService.cs
│   └── OrderServiceV2.cs
└── infra/                    # Infrastructure as Code (Bicep)
    ├── main.bicep            # Main deployment template
    ├── modules/              # Modular Bicep templates
    │   ├── network.bicep     # VNet and subnet configuration
    │   ├── apim.bicep        # API Management resources
    │   ├── appservice.bicep  # Web App hosting
    │   └── privateendpoint.bicep # Private endpoint configuration
    ├── api-definitions/      # API definitions for APIM
    │   ├── api-v1.json
    │   └── api-v2.json
    ├── deploy.sh            # Bash deployment script
    └── deploy.ps1           # PowerShell deployment script
```

## API Versions

### V1 API (Basic)

- Products API: Basic CRUD operations
- Orders API: Basic order management

### V2 API (Enhanced)

- Products API: Adds stock information, category search
- Orders API: Adds shipping details, order status, tracking information

## Getting Started

### Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Azure Subscription](https://azure.microsoft.com/free/)

### Running the API Locally

1. Clone the repository
2. Navigate to the project directory
3. Run the API:

```bash
cd APIMDemo
dotnet run
```

4. Access the Swagger UI: http://localhost:5000/swagger

### Deploying to Azure

#### Option 1: Using PowerShell

```powershell
cd APIMDemo/infra
./deploy.ps1 -SubscriptionId "<your-subscription-id>"
```

#### Option 2: Using Bash

```bash
cd APIMDemo/infra
chmod +x deploy.sh
./deploy.sh --subscription "<your-subscription-id>"
```

#### Option 3: Using GitHub Actions

You can deploy the infrastructure using the provided GitHub Action workflow:

1. Configure Azure credentials as GitHub secrets in your repository settings
2. Go to the Actions tab in your repository
3. Select the "Deploy APIM Infrastructure" workflow
4. Click "Run workflow" 
5. Fill in the required parameters and run the workflow

> Note: You'll need to add an `AZURE_CREDENTIALS` secret containing a service principal JSON to authenticate with Azure.

## Infrastructure Components

The deployed infrastructure includes:

- **Virtual Network**: Isolated network for all components
- **API Management**: API gateway with internal networking mode
- **Private Endpoint**: Secure connection to API Management
- **App Service**: Hosting for the API backend
- **Private DNS Zone**: For DNS resolution of the private endpoint

## Private Endpoints Architecture

The solution uses the following architecture:

1. A Virtual Network with subnets for:
   - API Management
   - Private Endpoints
   - Backend API

2. API Management deployed in internal mode
3. Private Endpoint in the Private Endpoint subnet
4. Private DNS Zone for name resolution
5. VNet Integration for the App Service

This ensures that traffic between components stays within the Azure network and isn't exposed to the public internet.

## API Management Features Demonstrated

- API Versioning
- Backend Services
- Products and Subscriptions
- API Definition Import
- Private Network Integration

## Additional Resources

- [Azure API Management Documentation](https://docs.microsoft.com/azure/api-management/)
- [Private Endpoints Documentation](https://docs.microsoft.com/azure/private-link/private-endpoint-overview)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
