locals {
  prefix-spoke2         = "spoke2"
}

resource "azurerm_virtual_network" "spoke2-vnet" {
  name                = "${local.prefix-spoke2}-vnet"
  location            = var.location
  resource_group_name = var.networkrg
  address_space       = ["10.2.0.0/16"]

  tags = {
    environment = local.prefix-spoke2
  }
}

resource "azurerm_subnet" "spoke2-mgmt" {
  name                 = "mgmt"
  resource_group_name  = var.networkrg
  virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
  address_prefixes     = ["10.2.0.64/27"]
}

resource "azurerm_subnet" "spoke2-workload" {
  name                 = "workload"
  resource_group_name  = var.networkrg
  virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "spoke2-hub-peer" {
  name                      = "${local.prefix-spoke2}-hub-peer"
  resource_group_name       = avar.networkrg
  virtual_network_name      = azurerm_virtual_network.spoke2-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = true
  depends_on = [azurerm_virtual_network.spoke2-vnet, azurerm_virtual_network.hub-vnet, azurerm_virtual_network_gateway.hub-vnet-gateway]
}

resource "azurerm_virtual_network_peering" "hub-spoke2-peer" {
  name                      = "hub-spoke2-peer"
  resource_group_name       = var.networkrg
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
  depends_on = [azurerm_virtual_network.spoke2-vnet, azurerm_virtual_network.hub-vnet, azurerm_virtual_network_gateway.hub-vnet-gateway]
}