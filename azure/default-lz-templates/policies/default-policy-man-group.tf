resource "azurerm_policy_definition" "example" {
  name         = "subscription-location-policy"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "subscription-location-policy"
  #management_group_name = azurerm_management_group.company_name

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
  name                 = "example-policy-assignment"
  scope                =  data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.example.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "My Example Policy Assignment"

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