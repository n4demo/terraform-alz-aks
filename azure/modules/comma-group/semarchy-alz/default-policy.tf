
#https://purple.telstra.com/blog/azure-policy-as-code-with-terraform-part-1

/*

resource "azurerm_policy_definition" "example" {
  name         = "subscription-location-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "subscription-location-policy"

  policy_rule = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS

}

resource "azurerm_policy_assignment" "example" {
  name                 = "location-policy"
  scope                = azurerm_management_group.company_name.id
  policy_definition_id = azurerm_policy_definition.example.id
  description          = "location-policy"
  display_name         = "location-policy"

  metadata = <<METADATA
    {
    "category": "General"
    }
METADATA

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value":["West Europe","North Europe","UK South","UK West"]
  }
}
PARAMETERS

}

*/