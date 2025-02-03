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
    name               = format("Aviatrix SSE Hub - %s", var.transit_gateway.vpc_reg)
    region             = lookup(local.azure_region_names, var.transit_gateway.vpc_reg)
    forwardingProfiles = local.profiles
    devicelinks        = local.links
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
  depends_on = [
    restapi_object.remote_network,
  ]
  create_duration = "90s"
}

resource "aviatrix_transit_external_device_conn" "sse_connection" {
  vpc_id                  = var.transit_gateway.vpc_id
  connection_name         = format("avx-sse-%s", lower(replace(var.transit_gateway.vpc_reg, " ", "-")))
  gw_name                 = var.transit_gateway.gw_name
  remote_gateway_ip       = local.is_ha ? format("%s,%s", local.sse_endpoint_config["links"][0]["localConfigurations"][0]["endpoint"], local.sse_endpoint_config["links"][1]["localConfigurations"][0]["endpoint"]) : local.sse_endpoint_config["links"][0]["localConfigurations"][0]["endpoint"]
  connection_type         = "bgp"
  bgp_local_as_num        = var.transit_gateway.local_as_number
  bgp_remote_as_num       = local.sse_endpoint_config["links"][0]["localConfigurations"][0]["asn"]
  ha_enabled              = false
  local_tunnel_cidr       = local.is_ha ? format("%s/30,%s/30", cidrhost(var.tunnel_subnets[0], 2), cidrhost(var.tunnel_subnets[1], 2)) : format("%s/30", cidrhost(var.tunnel_subnets[0], 2))
  remote_tunnel_cidr      = local.is_ha ? format("%s/30,%s/30", cidrhost(var.tunnel_subnets[0], 1), cidrhost(var.tunnel_subnets[1], 1)) : format("%s/30", cidrhost(var.tunnel_subnets[0], 1))
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
