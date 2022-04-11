resource "azurerm_policy_definition" "Six_Degrees_Audit_Policies" {
  name                 = "Six-Degrees-Audit-Policies"
  policy_type          = "Custom"
  mode                 = "All"
  display_name         = "Six-Degrees-Audit-Policies"

metadata = <<METADATA
    {
    "category": "General"
    }
METADATA

policy_rule = <<POLICY_RULE
    {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Authorization/roleAssignments"
        },
        {
          "field": "Microsoft.Authorization/roleAssignments/principalType",
          "equals": "[parameters('principalType')]"
        }
      ]
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

resource "azurerm_policy_assignment" "Six_Degrees_Audit_Policies" {
  name                 = "Six-Degrees-Audit-Policies"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.Six_Degrees_Audit_Policies.id
  description          = "Azure Policy that audit but do not make any changes."
  display_name         = "Six-Degrees-Audit-Policies"

  parameters = <<PARAMETERS
    {
      "LogAnalyticsWorkspaceName": {
        "type": "string",
        "metadata": {
          "description": "Name of the central Log Analytics workspace that stores security event and data collected by Azure Security Center"
        }
      },
      "LogAnalyticsWorkspaceRGName": {
        "type": "string",
        "metadata": {
          "description": "Name of the resource group where the central log analytics workspace belongs to"
        }
      },
      "auditDependencyagentdeployment-VMImage(OS)unlisted_listOfImageIdToInclude_windows": {
        "type": "array",
        "metadata": {
          "displayName": "Optional: List of VM images that have supported Windows OS to add to scope (Policy: Audit Dependency agent deployment - VM Image (OS) unlisted)"
        },
        "defaultValue": [],
        "allowedValues": []
      },
      "auditDependencyagentdeployment-VMImage(OS)unlisted_listOfImageIdToInclude_linux": {
        "type": "array",
        "metadata": {
          "displayName": "Optional: List of VM images that have supported Linux OS to add to scope (Policy: Audit Dependency agent deployment - VM Image (OS) unlisted)"
        },
        "defaultValue": [],
        "allowedValues": []
      },
      "auditDependencyagentdeployment-VMImage(OS)unlisted_listOfImageIdToInclude_windows": {
        "type": "array",
        "metadata": {
          "displayName": "Optional: List of VM images that have supported Windows OS to add to scope (Policy: Audit Dependency agent deployment - VM Image (OS) unlisted)"
        },
        "defaultValue": [],
        "allowedValues": []
      },
      "auditDependencyagentdeployment-VMImage(OS)unlisted_listOfImageIdToInclude_linux": {
        "type": "array",
        "metadata": {
          "displayName": "Optional: List of VM images that have supported Linux OS to add to scope (Policy: Audit Dependency agent deployment - VM Image (OS) unlisted)"
        },
        "defaultValue": [],
        "allowedValues": []
      },
      "azureVPNgatewaysshouldnotusebasicSKU_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Azure VPN gateways should not use 'basic' SKU)"
        },
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Disabled"
        ]
      },
      "deprecatedaccountswithownerpermissionsshouldberemovedfromyoursubscription_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Deprecated accounts with owner permissions should be removed from your subscription)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "diagnosticlogsinVirtualMachineScaleSetsshouldbeenabled_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Diagnostic logs in Virtual Machine Scale Sets should be enabled)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "endpointprotectionsolutionshouldbeinstalledonvirtualmachinescalesets_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Endpoint protection solution should be installed on virtual machine scale sets)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "auditdiagnosticsetting_listOfResourceTypes": {
        "type": "array",
        "metadata": {
          "displayName": "Resource Types (Policy: Audit diagnostic setting)",
          "strongType": "resourceTypes"
        },
        "defaultValue": [],
        "allowedValues": []
      },
      "microsoftIaaSAntimalwareextensionshouldbedeployedonWindowsservers_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Microsoft IaaSAntimalware extension should be deployed on Windows servers)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "deprecatedaccountsshouldberemovedfromyoursubscription_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Deprecated accounts should be removed from your subscription)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "vulnerabilityassessmentshouldbeenabledonyourSQLservers_effect_1": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Vulnerability assessment should be enabled on your SQL servers)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "azureBackupshouldbeenabledforVirtualMachines_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Azure Backup should be enabled for Virtual Machines)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "vulnerabilitiesonyourSQLdatabasesshouldberemediated_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Vulnerabilities on your SQL databases should be remediated)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "vulnerabilityassessmentshouldbeenabledonyourSQLmanagedinstances_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Vulnerability assessment should be enabled on your SQL managed instances)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "aPIAppshouldonlybeaccessibleoverHTTPS_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: API App should only be accessible over HTTPS)"
        },
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Disabled"
        ]
      },
      "fTPSshouldberequiredinyourWebApp_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: FTPS should be required in your Web App)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "functionAppshouldonlybeaccessibleoverHTTPS_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Function App should only be accessible over HTTPS)"
        },
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Disabled"
        ]
      },
      "rDPaccessfromtheInternetshouldbeblocked_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: RDP access from the Internet should be blocked)"
        },
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Disabled"
        ]
      },
      "sSHaccessfromtheInternetshouldbeblocked_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: SSH access from the Internet should be blocked)"
        },
        "defaultValue": "Audit",
        "allowedValues": [
          "Audit",
          "Disabled"
        ]
      },
      "microsoftAntimalwareforAzureshouldbeconfiguredtoautomaticallyupdateprotectionsignatures_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Microsoft Antimalware for Azure should be configured to automatically update protection signatures)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "managementportsshouldbeclosedonyourvirtualmachines_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Management ports should be closed on your virtual machines)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "systemupdatesonvirtualmachinescalesetsshouldbeinstalled_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: System updates on virtual machine scale sets should be installed)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "long-termgeo-redundantbackupshouldbeenabledforAzureSQLDatabases_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Long-term geo-redundant backup should be enabled for Azure SQL Databases)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "fTPSonlyshouldberequiredinyourAPIApp_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: FTPS only should be required in your API App)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "fTPSonlyshouldberequiredinyourFunctionApp_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: FTPS only should be required in your Function App)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "vulnerabilityAssessmentsettingsforSQLservershouldcontainanemailaddresstoreceivescanreports_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Vulnerability Assessment settings for SQL server should contain an email address to receive scan reports)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "vulnerabilitiesinsecurityconfigurationonyourvirtualmachinescalesetsshouldberemediated_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: Vulnerabilities in security configuration on your virtual machine scale sets should be remediated)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "theLogAnalyticsagentshouldbeinstalledonVirtualMachineScaleSets_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: The Log Analytics agent should be installed on Virtual Machine Scale Sets)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
      },
      "theLogAnalyticsagentshouldbeinstalledonvirtualmachines_effect": {
        "type": "string",
        "metadata": {
          "displayName": "Effect (Policy: The Log Analytics agent should be installed on virtual machines)"
        },
        "defaultValue": "AuditIfNotExists",
        "allowedValues": [
          "AuditIfNotExists",
          "Disabled"
        ]
        }
       }
      }
PARAMETERS

}