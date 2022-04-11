
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.43.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

variable "app_service_resource_group" {
    type = string
    description = "app_service_resource_group"
}

variable "app_service_plan_name" {
    type = string
    description = "app_service_plan_name"
}

variable "app_service_name" {
    type = string
    description = "app_service_name"
}

variable "location" {
    type = string
    description = "location"
}

resource "random_id" "app_name" {
  byte_length = 5
  prefix      = var.app_service_name
}

resource "azurerm_resource_group" "app_srv_rg" {
  name     = var.app_service_resource_group
  location = var.location
}

resource "azurerm_app_service_plan" "example" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.app_srv_rg.location
  resource_group_name = azurerm_resource_group.app_srv_rg.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "example" {
  name                = random_id.app_name.hex
  location            = azurerm_resource_group.app_srv_rg.location
  resource_group_name = azurerm_resource_group.app_srv_rg.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

}

