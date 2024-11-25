locals {

  azure_region_names = {
    "East US"              = "eastUS"
    "East US 2"            = "eastUS2"
    "West US"              = "westUS"
    "West US 2"            = "westUS2"
    "West US 3"            = "westUS3"
    "Central US"           = "centralUS"
    "North Central US"     = "northCentralUS"
    "South Central US"     = "southCentralUS"
    "West Central US"      = "westCentralUS"
    "North Europe"         = "northEurope"
    "West Europe"          = "westEurope"
    "France Central"       = "franceCentral"
    "Germany West Central" = "germanyWestCentral"
    "Switzerland North"    = "switzerlandNorth"
    "UK South"             = "ukSouth"
    "Canada East"          = "canadaEast"
    "Canada Central"       = "canadaCentral"
    "South Africa West"    = "southAfricaWest"
    "South Africa North"   = "southAfricaNorth"
    "UAE North"            = "uaeNorth"
    "Australia East"       = "australiaEast"
    "Central India"        = "centralIndia"
    "Southeast Asia"       = "southEastAsia"
    "Sweden Central"       = "swedenCentral"
    "South India"          = "southIndia"
    "Australia Southeast"  = "australiaSouthEast"
    "Korea Central"        = "koreaCentral"
    "Poland Central"       = "polandCentral"
    "Brazil South"         = "brazilSouth"
    "Japan East"           = "japanEast"
    "Japan West"           = "japanWest"
    "Korea South"          = "koreaSouth"
    "Italy North"          = "italyNorth"
    "France South"         = "franceSouth"
    "Israel Central"       = "israelCentral"
    "East Asia"            = "eastAsia"
    "Central US EUAP"      = "centralUSEUAP"
    "East US 2 EUAP"       = "eastUS2EUAP"
    "West India"           = "westIndia"
    "Germany North"        = "germanyNorth"
    "Norway East"          = "norwayEast"
    "Norway West"          = "norwayWest"
    "UAE Central"          = "uaeCentral"
    "Brazil Southeast"     = "brazilSoutheast"
    "Qatar Central"        = "qatarCentral"
    "China North"          = "chinaNorth"
    "China East"           = "chinaEast"
    "China North 2"        = "chinaNorth2"
    "China East 2"         = "chinaEast2"
    "Germany Central"      = "germanyCentral"
    "Germany Northeast"    = "germanyNortheast"
    "India South"          = "indiaSouth"
    "US DoD East"          = "usDoDEast"
    "US DoD Central"       = "usDoDCentral"
    "US Gov Virginia"      = "usGovVirginia"
    "US Gov Iowa"          = "usGovIowa"
    "US Gov Arizona"       = "usGovArizona"
    "US Gov Texas"         = "usGovTexas"
  }

  profiles = [for i in var.sse_forwarding_profiles :
    one([for profile in jsondecode(data.http.forwarding_profiles.response_body).value : { id = lookup(profile, "id", null) } if profile.trafficForwardingType == i])
  ]

  bearer_token           = jsondecode(data.http.azure_bearer_token.response_body).access_token
  sse_endpoint_config    = jsondecode(data.http.device_config.response_body)
  sse_endpoint_config_ha = local.is_ha ? jsondecode(data.http.device_config_ha[0].response_body) : null
  is_ha                  = !(var.transit_gateway.ha_gw_size == null || var.transit_gateway.ha_gw_size == "")
}
