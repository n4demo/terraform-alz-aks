
variable "company_man_group_name" {
    type = string
    description = "company managment group name"
}

# Create Management Group Structure
resource "azurerm_management_group" "company_name" {
  display_name = var.company_man_group_name
  subscription_ids = []
}

# Associate Management Group to subscription
#resource "azurerm_management_group_subscription_association" "prod" {
#  management_group_id = data.azurerm_management_group.company_name.id
#  subscription_id     = var.subscription_id 
#}


