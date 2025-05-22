@description('Resource ID of the resource to enable diagnostics on')
param resourceId string

@description('Name for the diagnostic settings')
param diagnosticSettingsName string

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('Resource type to enable diagnostics for')
@allowed([
  'vnet'
  'nsg'
  'pip'
  'loadBalancer'
  'appService'
])
param resourceType string

// Categories to enable for each resource type
var logCategories = {
  vnet: [
    {
      category: 'VMProtectionAlerts'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
  ]
  nsg: [
    {
      category: 'NetworkSecurityGroupEvent'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'NetworkSecurityGroupRuleCounter'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
  ]
  pip: [
    {
      category: 'DDoSProtectionNotifications'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'DDoSMitigationFlowLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'DDoSMitigationReports'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
  ]
  loadBalancer: [
    {
      category: 'LoadBalancerAlertEvent'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'LoadBalancerProbeHealthStatus'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
  ]
  appService: [
    {
      category: 'AppServiceHTTPLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'AppServiceConsoleLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'AppServiceAppLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'AppServiceAuditLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'AppServiceIPSecAuditLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
    {
      category: 'AppServicePlatformLogs'
      enabled: true
      retentionPolicy: {
        days: 30
        enabled: true
      }
    }
  ]
}

// Output the ARM template for diagnostic settings as a deployable object
output diagnosticsObject object = {
  name: diagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: logCategories[resourceType]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Output the resource ID for reference in the parent template
output targetResourceId string = resourceId
