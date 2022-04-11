variable "subscription_id" {
    type = string
    description = "SubscriptionId"
}

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

variable "environment_tag" {
    type = string
    description = "environment tag"
}

variable "function_tag" {
    type = string
    description = "function tag"
    default = ""
}

variable "customer_tag" {
    type = string
    description = "customer tag"
    default = ""
}

variable "project_tag" {
    type = string
    description = "project tag"
    default = ""
}

variable "owner_tag" {
    type = string
    description = "owner tag"
    default = ""
}

variable "costcentre_tag" {
    type = string
    description = "costcentre tag"
    default = ""
}

locals {
  common_tags = {
    environment  = "${var.environment_tag}"
    function     = "${var.function_tag}"
    customer     = "${var.customer_tag}"
    project      = "${var.project_tag}"  
    owner        = "${var.owner_tag}"
    costcentre   = "${var.costcentre_tag}"
  }
  extra_tags  = {
    other = ""
  }
}
 
