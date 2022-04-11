variable "location" {
  description = "Location of the network"
  default     = "uksouth"
}

variable "LocationAbbr" {
  description = "Abbreviation of the Location"
  default     = "uks"
}

variable "networkrg" {
  description = "Networking resource group"
  default     = "rg-uks-network"
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "vmadmin"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "Password1234!"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}