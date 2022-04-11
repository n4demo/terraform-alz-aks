
variable "vmss_resource_group" {
    type = string
    description = "vmss resource group"
}

variable "vmss_name" {
    type = string
    description = "vmss name"
}

resource "azurerm_resource_group" "vmss" {
  name     = var.vmss_resource_group
  location = var.location
  tags = "${merge( local.common_tags, local.extra_tags)}"
}

resource "random_id" "vmssname" {
  byte_length = 5
  prefix      = var.vmss_name
}

resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = random_id.vmssname.hex
  resource_group_name = azurerm_resource_group.vmss.name
  location            = azurerm_resource_group.vmss.location
  sku                 = "Standard_D2_v3"
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "pip-prd-uks-vmss"
      primary   = true
      subnet_id = azurerm_subnet.vmss.id
    }
  }
}

