
module "comma-group" {
  source = "../../../modules/default-lz-templates"
  company_man_group_name      = "acme" 
  subscription_id             = "xxxxx"
  location                    = "uk south"
  environment_tag             = "prod"
  function_tag                = "xxxxx"
  customer_tag                = "acme"
  project_tag                 = "xxxxx"
  owner_tag                   = "xxxxx"

  vnet_resource_group         = "rg-prd-uks-net-01"
  hub_vnet_name               = "vnet-prd-uks-<iprange>-hub"
  hub_vnet_address            = ["10.100.0.0/16"]
  hub_snet_name               = "AzureFirewallSubnet"
  hub_snet_address            = ["10.100.0.0/25"]
  hub_snet_name2              = "GatewaySubnet"
  hub_snet_address2           = ["10.100.0.128/27"]
  hub_snet_name3              = "Management"
  hub_snet_address3           = ["10.100.0.160/27"]

  spoke_vnet_name             = "vnet-prd-uks-<iprange>-spoke-01"
  spoke_vnet_address          = ["10.101.0.0/16"]
  spoke_snet_name             = "snet-prd-uks-<iprange>-spoke-01"
  spoke_snet_address          = ["10.101.0.0/24"]

  sa_resource_group           = "rg-prd-uks-sa-01"
  sa_name                     = "saprduk01"

  la_resource_group           = "rg-prd-uks-la-01"
  log_analytics_name          = "la-prd-uks-01"
  log_analytics_sku           = "Free"

  kv_resource_group           = "rg-prd-uks-kv-01"
  kv_name                     = "kv-prd-uks-01"

  aa_resource_group           = "rg-prd-uks-aa-01"
  aa_name                     = "aa-prd-uks-01"

  rsv_resource_group          = "rg-prd-ukw-rsv-01"
  rsv_name                    = "rsv-prd-ukw-01"
}


