/*
VNET-Hub            10.125.0.0/22   10.125.0.0  ->  10.125.3.255   1,024
DefaultSubnet       10.125.0.0/24   10.125.0.0  ->  10.125.0.255   256
AzureBastionSubnet  10.125.1.0/28   10.125.1.0  ->  10.125.1.15    16 

VNET-Spoke          10.126.0.0/22   10.126.0.0  ->  10.126.3.255   1,024
DefaultSubnet       10.126.0.0/24   10.126.0.0  ->  10.126.0.255   256
*/

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

variable "hub_snet_pip_name" {
    type = string
    description = "hub snet pip name"
}

variable "bastion_host_name" {
    type = string
    description = "bastion_host_name"
}

variable "bastion_snet_address" {
    type = list
    description = "bastion snet address"
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

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.bastion_snet_address
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

variable "vmss_snet_address" {
    type = list
    description = "vmss snet address"
}

variable "vmss_snet_name" {
    type = string
    description = "vmss snet name"
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  resource_group_name = azurerm_resource_group.vnet_rg.name
  address_space       = var.spoke_vnet_address
  location            = azurerm_resource_group.vnet_rg.location
  tags = "${merge(local.common_tags)}"
}

resource "azurerm_subnet" "spoke_snet" {
  name                 = var.spoke_snet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.spoke_snet_address
}

resource "azurerm_subnet" "vmss" {
  name                 = var.vmss_snet_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = var.vmss_snet_address
}

# VNET Peering
resource "azurerm_virtual_network_peering" "peerHubtoSpoke" {
  name                      = "peerHubtoSpoke"
  resource_group_name       = azurerm_resource_group.vnet_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peerSpoketoHub" {
  name                      = "peerSpoketoHub"
  resource_group_name       = azurerm_resource_group.vnet_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "random_id" "pipname" {
  byte_length = 5
  prefix      = var.hub_snet_pip_name
}

resource "azurerm_public_ip" "example" {
  name                = random_id.pipname.hex
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "example" {
  name                = var.bastion_host_name
  location            = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  ip_configuration {
    name                 = "pip-config"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

