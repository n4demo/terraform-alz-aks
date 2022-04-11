resource "azurerm_storage_account" "network_log_data" {
  name                      = "app1logdata"
  resource_group_name       = azurerm_resource_group.application1.name
  location                  = azurerm_resource_group.application1.location

  account_tier              = "Standard"
  account_replication_type  = "GRS"
  min_tls_version           = "TLS1_2"
}
