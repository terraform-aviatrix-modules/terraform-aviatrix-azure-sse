module "transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.6.0"

  cloud   = "azure"
  region  = "West Europe"
  cidr    = "10.1.0.0/23"
  account = "Azure"
  #ha_gw           = false
  local_as_number = 65001
}

module "sse" {
  source  = "terraform-aviatrix-modulesterraform-aviatrix-azure-sse/aviatrix"
  version = "1.0.0"

  azure_tenant_id     = "xxxxx"
  azure_client_id     = "xxxxx"
  azure_client_secret = "xxxxx"

  transit_gateway = module.transit.transit_gateway
}
