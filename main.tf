#Obtain Azure API bearer token
data "http" "azure_bearer_token" {
  url    = "https://login.microsoftonline.com/${var.azure_tenant_id}/oauth2/token"
  method = "POST"

  request_headers = {
    Accept = "application/x-www-form-urlencoded"
  }

  request_body = format("grant_type=client_credentials&client_id=%s&client_secret=%s&resource=https://graph.microsoft.com/", var.azure_client_id, var.azure_client_secret)
}

#Fetch forwarding profiles
data "http" "forwarding_profiles" {
  url = "https://graph.microsoft.com/beta/networkAccess/forwardingProfiles"
  request_headers = {
    Authorization = "Bearer ${local.bearer_token}"
    Accept        = "application/json"
  }
}

#Create random PSK
resource "random_password" "psk" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Create remote network
resource "restapi_object" "remote_network" {
  provider = restapi
  path     = "/"
  data = jsonencode({
    name   = format("Aviatrix SSE Hub - %s", var.transit_gateway.vpc_reg)
    region = "centralUS" #Hardcoded for beta
    # region             = lookup(local.azure_region_names, var.transit_gateway.vpc_reg)
    forwardingProfiles = local.profiles
    devicelinks = [
      {
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
    ]
  })
}

data "http" "device_config" {
  url = "https://graph.microsoft.com/beta/networkAccess/connectivity/remoteNetworks/${restapi_object.remote_network.id}/connectivityConfiguration"
  request_headers = {
    Authorization = "Bearer ${local.bearer_token}"
    Accept        = "application/json"
  }
  depends_on = [time_sleep.wait_for_sse_endpoint]
}

resource "time_sleep" "wait_for_sse_endpoint" {
  depends_on      = [restapi_object.remote_network]
  create_duration = "90s"
}

output "test" {
  value = local.profiles
}

resource "aviatrix_transit_external_device_conn" "sse_connection" {
  vpc_id                  = var.transit_gateway.vpc_id
  connection_name         = format("avx-sse-%s", lower(replace(var.transit_gateway.vpc_reg, " ", "-")))
  gw_name                 = var.transit_gateway.gw_name
  remote_gateway_ip       = local.sse_endpoint_config["links"][0]["localConfigurations"][0]["endpoint"]
  connection_type         = "bgp"
  bgp_local_as_num        = var.transit_gateway.local_as_number
  bgp_remote_as_num       = local.sse_endpoint_config["links"][0]["localConfigurations"][0]["asn"]
  ha_enabled              = false
  local_tunnel_cidr       = format("%s/30", cidrhost(var.tunnel_subnets[0], 2))
  remote_tunnel_cidr      = format("%s/30", cidrhost(var.tunnel_subnets[0], 1))
  custom_algorithms       = true
  pre_shared_key          = random_password.psk.result
  phase_1_authentication  = "SHA-256"
  phase_2_authentication  = "HMAC-SHA-256"
  phase_1_dh_groups       = "14"
  phase_2_dh_groups       = "14"
  phase_1_encryption      = "AES-128-CBC"
  phase_2_encryption      = "NULL-ENCR"
  phase1_local_identifier = null
  enable_ikev2            = true
}
