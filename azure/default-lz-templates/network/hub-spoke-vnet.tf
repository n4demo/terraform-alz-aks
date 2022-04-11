
variable "vnet_resource_group" {
    type = string
    description = "hub vnet resource group"
}

variable "hub_vnet_name" {
    type = string
    description = "hub vnet name"
}

variable "hub_vnet_address" {
    type = list
    description = "hub vnet address"
}

variable "hub_snet_name" {
    type = string
    description = "hub snet name"
}

variable "hub_snet_address" {
    type = list
    description = "hub snet address"
}

variable "hub_snet_name2" {
  type = list
  description = "hub snet name2"
}

variable "hub_snet_name3" {
  type = list
  description = "hub snet name3"
}

resource "azurerm_resource_group" "vnet_rg" {
  name     = var.vnet_resource_group
  location = var.location

    tags = {
    Environment = var.environment_tag,
    Function    = var.function_tag
  }
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = var.hub_vnet_address
  location            = var.location
}

resource "azurerm_subnet" "hub_snet" {
  name                 = var.hub_snet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.hub_snet_address
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

variable "spoke_vnet_name" {
    type = string
    description = "spoke vnet name"
}

variable "spoke_vnet_address" {
    type = list
    description = "spoke vnet address"
}

variable "spoke_snet_address" {
    type = list
    description = "spoke snet address"
}

variable "spoke_snet_name" {
    type = string
    description = "spoke snet name"
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = var.spoke_vnet_address
  location            = var.location
  tags = "${merge(local.common_tags)}"
}

resource "azurerm_subnet" "spoke_snet" {
  name                 = var.spoke_snet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.spoke_snet_address
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

# VNET Peering
resource "azurerm_virtual_network_peering" "peerHubtoSpoke" {
  name                      = "peerHubtoSpoke"
  resource_group_name       = azurerm_resource_group.vnet_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_virtual_network_peering" "peerSpoketoHub" {
  name                      = "peerSpoketoHub"
  resource_group_name       = azurerm_resource_group.vnet_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

