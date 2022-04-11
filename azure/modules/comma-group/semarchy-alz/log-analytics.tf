
variable "la_resource_group" {
    type = string
    description = "la_resource_group"
}

variable "log_analytics_name" {
    type = string
    description = "log analytics name"
}

variable "log_analytics_sku" {
    type = string
    description = "log analytics sku"
}

resource "azurerm_resource_group" "la" {
  name     = var.la_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "azurerm_log_analytics_workspace" "laws" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = azurerm_resource_group.la.name
  sku                 = var.log_analytics_sku
  retention_in_days   = 7
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

