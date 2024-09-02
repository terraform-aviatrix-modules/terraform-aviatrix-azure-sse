# terraform-aviatrix-azure-sse

### Description
This module facilitates easy integration between Aviatrix and Microsoft Azure's Security Service Edge.

As Azure's Terraform provider currently does not yet support the creation of the Security Services Edge resources, this module depends on directly calling the Azure API.

### Diagram
\<Provide a diagram of the high level constructs thet will be created by this module>
<img src="<IMG URL>"  height="250">

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v0.0.1 | >= 1.0 | 7.0 | >= 3.0.0

### Usage Example
```hcl
module "transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.3"

  cloud           = "azure"
  region          = "West Europe"
  cidr            = "10.1.0.0/23"
  account         = "Azure"
  ha_gw           = false
  local_as_number = 65001
}

module "sse" {
  source = "terraform-aviatrix-modulesterraform-aviatrix-azure-sse/aviatrix"
  version = "0.0.1"

  azure_tenant_id     = "xxxxx"
  azure_client_id     = "xxxxx"
  azure_client_secret = "xxxxx"

  transit_gateway = module.transit.transit_gateway
}
```

### Variables
The following variables are required:

key | value
:--- | :---
 | \<description of value that should be provided in this variable>
azure_tenant_id | Azure tenant id
azure_client_id | Azure client id
azure_client_secret | Azure client secret
transit_gateway | The Aviatrix transit gateway object

The following variables are optional:

key | default | value 
:---|:---|:---
sse_forwarding_profiles | ["m365"] | Selects the forwarding profiles.
sse_bandwidth | 250 | Sets the bandwidth per tunnel.
tunnel_subnets | ["169.254.0.0/30","169.254.0.4/30"] | Determines which tunnel addresses are used.

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>



