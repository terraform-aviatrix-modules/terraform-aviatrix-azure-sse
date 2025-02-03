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

  bearer_token        = jsondecode(data.http.azure_bearer_token.response_body).access_token
  sse_endpoint_config = jsondecode(data.http.device_config.response_body)
  is_ha               = !(var.transit_gateway.ha_gw_size == null || var.transit_gateway.ha_gw_size == "")

  primary_gw_link = {
    name                    = "AVX-Transit"
    ipAddress               = var.transit_gateway.public_ip
    bandwidthCapacityInMbps = format("mbps%s", var.sse_bandwidth)
    deviceVendor            = "other"
    bgpConfiguration = {
      localIpAddress = cidrhost(var.tunnel_subnets[0], 1)
      peerIpAddress  = cidrhost(var.tunnel_subnets[0], 2)
      asn            = var.transit_gateway.local_as_number
    }
    redundancyConfiguration = {
      zoneLocalIpAddress = null
      redundancyTier     = "noRedundancy"
    }
    tunnelConfiguration = {
      "@odata.type"              = "#microsoft.graph.networkaccess.tunnelConfigurationIKEv2Custom"
      preSharedKey               = random_password.psk.result
      zoneRedundancyPreSharedKey = null
      saLifeTimeSeconds          = 300
      ipSecEncryption            = "none"
      ipSecIntegrity             = "sha256"
      ikeEncryption              = "aes128"
      ikeIntegrity               = "sha256"
      dhGroup                    = "dhGroup14"
      pfsGroup                   = "pfs14"
    }
  }

  ha_gw_link = {
    name                    = "AVX-Transit-HA"
    ipAddress               = var.transit_gateway.ha_public_ip
    bandwidthCapacityInMbps = format("mbps%s", var.sse_bandwidth)
    deviceVendor            = "other"
    bgpConfiguration = {
      localIpAddress = cidrhost(var.tunnel_subnets[1], 1)
      peerIpAddress  = cidrhost(var.tunnel_subnets[1], 2)
      asn            = var.transit_gateway.local_as_number
    }
    redundancyConfiguration = {
      zoneLocalIpAddress = null
      redundancyTier     = "noRedundancy"
    }
    tunnelConfiguration = {
      "@odata.type"              = "#microsoft.graph.networkaccess.tunnelConfigurationIKEv2Custom"
      preSharedKey               = random_password.psk.result
      zoneRedundancyPreSharedKey = null
      saLifeTimeSeconds          = 300
      ipSecEncryption            = "none"
      ipSecIntegrity             = "sha256"
      ikeEncryption              = "aes128"
      ikeIntegrity               = "sha256"
      dhGroup                    = "dhGroup14"
      pfsGroup                   = "pfs14"
    }
  }

  links = local.is_ha ? [local.primary_gw_link, local.ha_gw_link] : [local.primary_gw_link]
}
