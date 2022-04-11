
variable "kv_resource_group" {
    type = string
    description = "kv_resource_group"
}

variable "kv_name" {
    type = string
    description = "key vault account name"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "kv" {
  name     = var.kv_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "random_id" "kvname" {
  byte_length = 5
  prefix      = var.kv_name
}

resource "azurerm_key_vault" "kv" {
  name                        = random_id.kvname.hex
  location                    = var.location
  resource_group_name         = azurerm_resource_group.kv.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  tags = "${merge( local.common_tags, local.extra_tags)}"

  access_policy {

    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

     secret_permissions = [
      "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

