

/*
VNET-Hub            10.125.0.0/22   10.125.0.0  ->  10.125.3.255   1,024
DefaultSubnet       10.125.0.0/24   10.125.0.0  ->  10.125.0.255   256
AzureBastionSubnet  10.125.1.0/28   10.125.1.0  ->  10.125.1.15    16 

VNET-Spoke          10.126.0.0/22   10.126.0.0  ->  10.126.3.255   1,024
DefaultSubnet       10.126.0.0/24   10.126.0.0  ->  10.126.0.255   256
VmssSubnet          10.126.1.0/27   10.126.1.0  ->  10.126.1.31    32
*/

module "comma-group" {
  source = "../../../modules/comma-group/semarchy-alz"
  company_man_group_name      = "acme" 
  subscription_id             = "d4e9e8b9-0299-41db-8666-80b5b30ea96a"
  location                    = "uk south"
  environment_tag             = "prod"
  function_tag                = "Semarchy"
  customer_tag                = "acme"
  project_tag                 = "Semarchy"
  owner_tag                   = "Comma-Group"
  costcentre_tag              = "3321"

  vnet_resource_group         = "rg-prd-uks-net-01"
  hub_vnet_name               = "vnet-prd-uks-hub-01"
  hub_vnet_address            = ["10.125.0.0/22"]
  hub_snet_name               = "snet-prd-uks-hub-01"
  hub_snet_address            = ["10.125.0.0/24"]
  hub_snet_pip_name           = "pip-prd-uks-"   
  bastion_host_name           = "bast-prd-uks-01" 
  bastion_snet_address        = ["10.125.1.0/28"]
  
  spoke_vnet_name             = "vnet-prd-uks-spoke-01"
  spoke_vnet_address          = ["10.126.0.0/22"]
  spoke_snet_name             = "snet-prd-uks-spoke-01"
  spoke_snet_address          = ["10.126.0.0/24"]
  vmss_snet_name              = "snet-prd-uks-vmss-01"
  vmss_snet_address           = ["10.126.1.0/27"]
  
  sa_resource_group           = "rg-prd-uks-sa-01"
  sa_name                     = "saprduk01"

  la_resource_group           = "rg-prd-uks-la-01"
  log_analytics_name          = "la-prd-uks-01"
  log_analytics_sku           = "Free"

  kv_resource_group           = "rg-prd-uks-kv-01"
  kv_name                     = "kv-prd-uks-"

  aa_resource_group           = "rg-prd-uks-aa-01"
  aa_name                     = "aa-prd-uks-01"

  rsv_resource_group          = "rg-prd-ukw-rsv-01"
  rsv_name                    = "rsv-prd-ukw-01"

  vmss_resource_group         = "rg-prd-uks-vmss-01"
  vmss_name                   = "vmss-prd-uks-01"
}