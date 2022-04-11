## Create Management jumpbox VM
variable "location" {
    type = string
    description = "location"
    default = "uksouth"
}

variable "allowedLocations" {
    type = list
    description = "location"
    default = ["West Europe","North Europe","UK South","UK West"] 
}

## Create Management VM resource group
resource "azurerm_resource_group" "rg" {
  name     = "ManagementVM-RG"
  location = "UK South"
}

## Create Availability set
resource "azurerm_availability_set" "DemoAset" {
  name                = "example-aset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

## Create network interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
  }
}

## Create public IP
resource "azurerm_public_ip" "mgmtpublicip" {
    name                         = "mgmtPublicIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
}

## Create Storage account for Diagnostics
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = azurerm_resource_group.rg.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

## Create Management VM
resource "azurerm_windows_virtual_machine" "mgmtvm" {
  name                = "6dg-uks-mgmt01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_b2ms"
  tags                = {
      "Managed By" = "Six Degrees Group"
      "Description" = "Six Degrees Management Jumpbox"
      "Management Class" = "VM"
      "Management Tier" = "1"
  }
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  availability_set_id = azurerm_availability_set.DemoAset.id
  network_interface_ids = [
    azurerm_network_interface.example.id,azurerm_public_ip.mgmtpublicip.id
  ]

  os_disk {
    name                 = azurerm_windows_virtual_machine.name._osDisk
    caching              = "ReadWrite"
    createOption         = "FromImage"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
   boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
}

## Add VM extensions
resource "azurerm_virtual_machine_extension" "AV" {
    name                       = "${local.prefix}${count.index + 1}-av"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    virtual_machine_name       = azurerm_windows_virtual_machine.mgmtvm.name
    publisher                  = "Microsoft.Azure.Security"
    type                       = "IaaSAntimalware"
    type_handler_version       = "1.3"
    auto_upgrade_minor_version = "true"
  
    settings = <<SETTINGS
    {
      "AntimalwareEnabled": true,
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
      "isEnabled": "true",
      "day": "7",
      "time": "120",
      "scanType": "Quick"
      },
      "Exclusions": {
      "Extensions": "",
      "Paths": "",
      "Processes": ""
      }
    }
  SETTINGS
  }

  resource "azurerm_virtual_machine_extension" "MMA" {
    name                       = "${local.prefix}${count.index + 1}-ma"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    virtual_machine_name       = azurerm_windows_virtual_machine.mgmtvm.name
    publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
    type                       = "MicrosoftMonitoringAgent"
    type_handler_version       = "1.0"
    auto_upgrade_minor_version = "true"
  
    settings = <<SETTINGS
    {
    "workspaceId": "[reference(resourceId(parameters('omsWorkspaceResourceGroup'), 'microsoft.operationalinsights/workspaces/', parameters('omsWorkspaceName')), '2015-03-20').customerId]"
    }
  SETTINGS
   protected_settings = <<PROTECTED_SETTINGS
    {
    "workspaceKey": "[listKeys(resourceId(parameters('omsWorkspaceResourceGroup'), 'microsoft.operationalinsights/workspaces/', parameters('omsWorkspaceName')), '2015-11-01-preview').primarySharedKey]"
    }
  PROTECTED_SETTINGS
  }

  resource "azurerm_virtual_machine_extension" "ADE" {
    name                       = "${local.prefix}${count.index + 1}-ade"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    virtual_machine_name       = azurerm_windows_virtual_machine.mgmtvm.name
    publisher                  = "Microsoft.Azure.Security"
    type                       = "AzureDiskEncryption"
    type_handler_version       = "2.2"
    auto_upgrade_minor_version = "true"
  
    settings = <<SETTINGS
    {
      "EncryptionOperation": "EnableEncryption",
              "KeyVaultURL": "[reference(resourceId(parameters('keyVaultResourceGroup'), 'Microsoft.KeyVault/vaults/', parameters('keyVaultName')),'2016-10-01').vaultUri]",
              "KeyVaultResourceId": "[resourceId(parameters('keyVaultResourceGroup'), 'Microsoft.KeyVault/vaults/', parameters('keyVaultName'))]",
              "KeyEncryptionKeyURL": "",
              "KekVaultResourceId": "[resourceId(parameters('keyVaultResourceGroup'), 'Microsoft.KeyVault/vaults/', parameters('keyVaultName'))]",
              "KeyEncryptionAlgorithm": "RSA-OAEP",
              "VolumeType": "All",
              "ResizeOSDisk": false
    }
  SETTINGS
  }

  resource "azurerm_virtual_machine_extension" "VMdiag" {
    name                       = "${local.prefix}${count.index + 1}-vmadiag"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    virtual_machine_name       = azurerm_windows_virtual_machine.mgmtvm.name
    publisher                  = "Microsoft.Azure.Diagnostics"
    type                       = "IaaSDiagnostics"
    type_handler_version       = "1.5"
    auto_upgrade_minor_version = "true"
  
    settings = <<SETTINGS
    {
     "StorageAccount": "[variables('diagStorAccName')]",
              "xmlCfg": "PFdhZENmZz4gPERpYWdub3N0aWNNb25pdG9yQ29uZmlndXJhdGlvbiBvdmVyYWxsUXVvdGFJbk1CPSI0MDk2IiB4bWxucz0iaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS9TZXJ2aWNlSG9zdGluZy8yMDEwLzEwL0RpYWdub3N0aWNzQ29uZmlndXJhdGlvbiI+IDxEaWFnbm9zdGljSW5mcmFzdHJ1Y3R1cmVMb2dzIHNjaGVkdWxlZFRyYW5zZmVyTG9nTGV2ZWxGaWx0ZXI9IkVycm9yIiBzY2hlZHVsZWRUcmFuc2ZlclBlcmlvZD0iUFQxTSIvPiA8V2luZG93c0V2ZW50TG9nIHNjaGVkdWxlZFRyYW5zZmVyUGVyaW9kPSJQVDFNIj4gPERhdGFTb3VyY2UgbmFtZT0iQXBwbGljYXRpb24hKltTeXN0ZW1bKExldmVsPTEgb3IgTGV2ZWw9MiBvciBMZXZlbD0zKV1dIi8+IDxEYXRhU291cmNlIG5hbWU9IlNlY3VyaXR5ISpbU3lzdGVtWyhiYW5kKEtleXdvcmRzLDQ1MDM1OTk2MjczNzA0OTYpKV1dIi8+IDxEYXRhU291cmNlIG5hbWU9IlN5c3RlbSEqW1N5c3RlbVsoTGV2ZWw9MSBvciBMZXZlbD0yIG9yIExldmVsPTMpXV0iLz48L1dpbmRvd3NFdmVudExvZz48UGVyZm9ybWFuY2VDb3VudGVycyBzY2hlZHVsZWRUcmFuc2ZlclBlcmlvZD0iUFQxTSI+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFByb2Nlc3NvciBJbmZvcm1hdGlvbihfVG90YWwpXCUgUHJvY2Vzc29yIFRpbWUiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJQZXJjZW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFByb2Nlc3NvciBJbmZvcm1hdGlvbihfVG90YWwpXCUgUHJpdmlsZWdlZCBUaW1lIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iUGVyY2VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxQcm9jZXNzb3IgSW5mb3JtYXRpb24oX1RvdGFsKVwlIFVzZXIgVGltZSIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IlBlcmNlbnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcUHJvY2Vzc29yIEluZm9ybWF0aW9uKF9Ub3RhbClcUHJvY2Vzc29yIEZyZXF1ZW5jeSIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFN5c3RlbVxQcm9jZXNzZXMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxQcm9jZXNzKF9Ub3RhbClcVGhyZWFkIENvdW50IiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcUHJvY2VzcyhfVG90YWwpXEhhbmRsZSBDb3VudCIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFN5c3RlbVxTeXN0ZW0gVXAgVGltZSIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFN5c3RlbVxDb250ZXh0IFN3aXRjaGVzL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50UGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXFN5c3RlbVxQcm9jZXNzb3IgUXVldWUgTGVuZ3RoIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTWVtb3J5XCUgQ29tbWl0dGVkIEJ5dGVzIEluIFVzZSIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IlBlcmNlbnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTWVtb3J5XEF2YWlsYWJsZSBCeXRlcyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXE1lbW9yeVxDb21taXR0ZWQgQnl0ZXMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJCeXRlcyIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxNZW1vcnlcQ2FjaGUgQnl0ZXMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJCeXRlcyIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxNZW1vcnlcUG9vbCBQYWdlZCBCeXRlcyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXE1lbW9yeVxQb29sIE5vbnBhZ2VkIEJ5dGVzIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXMiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTWVtb3J5XFBhZ2VzL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50UGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXE1lbW9yeVxQYWdlIEZhdWx0cy9zZWMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudFBlclNlY29uZCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxQcm9jZXNzKF9Ub3RhbClcV29ya2luZyBTZXQiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxQcm9jZXNzKF9Ub3RhbClcV29ya2luZyBTZXQgLSBQcml2YXRlIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVwlIERpc2sgVGltZSIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IlBlcmNlbnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVwlIERpc2sgUmVhZCBUaW1lIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iUGVyY2VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXCUgRGlzayBXcml0ZSBUaW1lIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iUGVyY2VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXCUgSWRsZSBUaW1lIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iUGVyY2VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXERpc2sgQnl0ZXMvc2VjIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXNQZXJTZWNvbmQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVxEaXNrIFJlYWQgQnl0ZXMvc2VjIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXNQZXJTZWNvbmQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVxEaXNrIFdyaXRlIEJ5dGVzL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzUGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXExvZ2ljYWxEaXNrKF9Ub3RhbClcRGlzayBUcmFuc2ZlcnMvc2VjIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXNQZXJTZWNvbmQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVxEaXNrIFJlYWRzL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzUGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXExvZ2ljYWxEaXNrKF9Ub3RhbClcRGlzayBXcml0ZXMvc2VjIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXNQZXJTZWNvbmQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVxBdmcuIERpc2sgc2VjL1RyYW5zZmVyIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTG9naWNhbERpc2soX1RvdGFsKVxBdmcuIERpc2sgc2VjL1JlYWQiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXEF2Zy4gRGlzayBzZWMvV3JpdGUiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXEF2Zy4gRGlzayBRdWV1ZSBMZW5ndGgiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXEF2Zy4gRGlzayBSZWFkIFF1ZXVlIExlbmd0aCIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXExvZ2ljYWxEaXNrKF9Ub3RhbClcQXZnLiBEaXNrIFdyaXRlIFF1ZXVlIExlbmd0aCIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkNvdW50Ii8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXExvZ2ljYWxEaXNrKF9Ub3RhbClcJSBGcmVlIFNwYWNlIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iUGVyY2VudCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxMb2dpY2FsRGlzayhfVG90YWwpXEZyZWUgTWVnYWJ5dGVzIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTmV0d29yayBJbnRlcmZhY2UoKilcQnl0ZXMgVG90YWwvc2VjIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQnl0ZXNQZXJTZWNvbmQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTmV0d29yayBJbnRlcmZhY2UoKilcQnl0ZXMgU2VudC9zZWMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJCeXRlc1BlclNlY29uZCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxOZXR3b3JrIEludGVyZmFjZSgqKVxCeXRlcyBSZWNlaXZlZC9zZWMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJCeXRlc1BlclNlY29uZCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxOZXR3b3JrIEludGVyZmFjZSgqKVxQYWNrZXRzL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzUGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXE5ldHdvcmsgSW50ZXJmYWNlKCopXFBhY2tldHMgU2VudC9zZWMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJCeXRlc1BlclNlY29uZCIvPjxQZXJmb3JtYW5jZUNvdW50ZXJDb25maWd1cmF0aW9uIGNvdW50ZXJTcGVjaWZpZXI9IlxOZXR3b3JrIEludGVyZmFjZSgqKVxQYWNrZXRzIFJlY2VpdmVkL3NlYyIgc2FtcGxlUmF0ZT0iUFQ2MFMiIHVuaXQ9IkJ5dGVzUGVyU2Vjb25kIi8+PFBlcmZvcm1hbmNlQ291bnRlckNvbmZpZ3VyYXRpb24gY291bnRlclNwZWNpZmllcj0iXE5ldHdvcmsgSW50ZXJmYWNlKCopXFBhY2tldHMgT3V0Ym91bmQgRXJyb3JzIiBzYW1wbGVSYXRlPSJQVDYwUyIgdW5pdD0iQ291bnQiLz48UGVyZm9ybWFuY2VDb3VudGVyQ29uZmlndXJhdGlvbiBjb3VudGVyU3BlY2lmaWVyPSJcTmV0d29yayBJbnRlcmZhY2UoKilcUGFja2V0cyBSZWNlaXZlZCBFcnJvcnMiIHNhbXBsZVJhdGU9IlBUNjBTIiB1bml0PSJDb3VudCIvPjwvUGVyZm9ybWFuY2VDb3VudGVycz48TWV0cmljcyByZXNvdXJjZUlkPSIvc3Vic2NyaXB0aW9ucy8wZGUyMzg1Zi1jYzFhLTQwMDUtODllZS05ZjQzMDBiZGExNDgvcmVzb3VyY2VHcm91cHMvc3N5c2cvcHJvdmlkZXJzL01pY3Jvc29mdC5Db21wdXRlL3ZpcnR1YWxNYWNoaW5lcy9zc3lwYXpyZHMzIj48TWV0cmljQWdncmVnYXRpb24gc2NoZWR1bGVkVHJhbnNmZXJQZXJpb2Q9IlBUMUgiLz48TWV0cmljQWdncmVnYXRpb24gc2NoZWR1bGVkVHJhbnNmZXJQZXJpb2Q9IlBUMU0iLz48L01ldHJpY3M+PERpcmVjdG9yaWVzLz48L0RpYWdub3N0aWNNb25pdG9yQ29uZmlndXJhdGlvbj48L1dhZENmZz4="
    }
  SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
    {
              "storageAccountName": "[variables('diagStorAccName')]",
              "storageAccountKey": "[listKeys(resourceId('Microsoft.Storage/storageAccounts', variables('diagStorAccName')), providers('Microsoft.Storage', 'storageAccounts').apiVersions[0]).keys[0].value]",
              "storageAccountEndPoint": "https://core.windows.net"
            }
  PROTECTED_SETTINGS
  }

  resource "azurerm_virtual_machine_extension" "depa" {
    name                       = "${local.prefix}${count.index + 1}-depa"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    virtual_machine_name       = azurerm_windows_virtual_machine.mgmtvm.name
    publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
    type                       = "DependencyAgentWindows"
    type_handler_version       = "9.5"
    auto_upgrade_minor_version = "true"
  
    settings = <<SETTINGS
    {}
  SETTINGS