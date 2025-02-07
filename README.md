<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-microsoft-entra-sse

### Description
This module facilitates easy integration between Aviatrix and Microsoft's Security Service Edge.

As Microsoft's Terraform provider currently does not yet support the creation of the Security Services Edge resources, this module depends on directly calling the Microsoft Graph API.

> [!WARNING]
>Be aware as of the date of publishing this module, the Microsoft Graph API v1.0 does not yet support the remote network API's, as they are in preview. This module uses the beta version of the graph API, which may be subject to change.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.2.0 | >=1.3 | >= 7.0 | >= 3.0.0

### Usage Example
```hcl
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
  source  = "terraform-aviatrix-modules/microsoft-entra-sse/aviatrix"
  version = "1.2.0"

  azure_tenant_id     = "xxxxx"
  azure_client_id     = "xxxxx"
  azure_client_secret = "xxxxx"
  location            = "West Europe"

  transit_gateway = module.transit.transit_gateway
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Azure Client ID | `any` | n/a | yes |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | Azure Client Secret | `any` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure Tenant ID | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to provision the SSE remote network. E.g. "East US". | `string` | n/a | yes |
| <a name="input_redundancy"></a> [redundancy](#input\_redundancy) | Specifies the Device link SKU .The possible values are: noRedundancy, zoneRedundancy. | `string` | `"noRedundancy"` | no |
| <a name="input_sse_bandwidth"></a> [sse\_bandwidth](#input\_sse\_bandwidth) | The desired bandwidth in Mbps. | `number` | `250` | no |
| <a name="input_sse_forwarding_profiles"></a> [sse\_forwarding\_profiles](#input\_sse\_forwarding\_profiles) | List of the desired forwarding profiles | `list` | <pre>[<br/>  "m365"<br/>]</pre> | no |
| <a name="input_transit_gateway"></a> [transit\_gateway](#input\_transit\_gateway) | The Aviatix transit gateway object | `any` | n/a | yes |
| <a name="input_tunnel_subnets"></a> [tunnel\_subnets](#input\_tunnel\_subnets) | n/a | `list` | <pre>[<br/>  "169.254.0.0/30",<br/>  "169.254.0.4/30"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->