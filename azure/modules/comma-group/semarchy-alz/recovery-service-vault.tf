
variable "rsv_resource_group" {
    type = string
    description = "recovery service vault resource group"
}

variable "rsv_name" {
    type = string
    description = "recovery service vault name"
}

resource "azurerm_resource_group" "rsv" {
  name     = var.rsv_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}" 
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = var.rsv_name
  location            = azurerm_resource_group.rsv.location
  resource_group_name = azurerm_resource_group.rsv.name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

