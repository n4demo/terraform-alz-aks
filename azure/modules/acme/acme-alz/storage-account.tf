
variable "sa_resource_group" {
    type = string
    description = "sa_resource_group"
}

variable "sa_name" {
    type = string
    description = "storage account name"
}

resource "azurerm_resource_group" "sa_rg" {
  name     = var.sa_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "azurerm_storage_account" "sa_name" {
  name                     = var.sa_name
  resource_group_name      = azurerm_resource_group.sa_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [azurerm_log_analytics_workspace.laws]
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "azurerm_log_analytics_linked_storage_account" "lsa" {
  data_source_type      = "customlogs"
  resource_group_name   = azurerm_resource_group.la.name
  workspace_resource_id = azurerm_log_analytics_workspace.laws.id
  storage_account_ids   = [azurerm_storage_account.sa_name.id]
}
