variable "aa_resource_group" {
    type = string
    description = "automation account resource group"
}

variable "aa_name" {
    type = string
    description = "automation account name"
}

resource "azurerm_resource_group" "aa" {
  name     = var.aa_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "azurerm_automation_account" "example" {
  name                = var.aa_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aa.name
  sku_name = "Basic"
  tags = "${merge( local.common_tags, local.extra_tags)}"
}