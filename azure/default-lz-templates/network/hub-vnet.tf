locals {
  prefix-hub         = "hub"
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${local.prefix-hub}-vnet"
  location            = var.location
  resource_group_name = var.networkrg
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "hub-spoke"
  }
}

resource "azurerm_subnet" "hub-gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.networkrg
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.0.128/27"]
}

resource "azurerm_subnet" "hub-mgmt" {
  name                 = "Management"
  resource_group_name  = var.networkrg
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes       = ["10.0.0.160/27"]
}

resource "azurerm_subnet" "hub-firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.networkrg
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes       = ["10.0.0.0/25"]
}
