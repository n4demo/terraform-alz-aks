
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-prd-uks-acr-01"
  location = "UK South"
}

resource "random_id" "acrname" {
  byte_length = 5
  prefix      = "acrprduks"
}

resource "azurerm_container_registry" "acr" {
  # name                     = random_id.acrname.hex
  name                     = "acrprduks"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Standard"
  admin_enabled            = true
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}