provider "restapi" {
  uri                  = "https://graph.microsoft.com/beta/networkAccess/connectivity/remoteNetworks"
  write_returns_object = true
  debug                = true

  headers = {
    Authorization = "Bearer ${local.bearer_token}"
    Content-Type  = "application/json"
  }

  create_method  = "POST"
  update_method  = "PUT"
  destroy_method = "DELETE"
}
