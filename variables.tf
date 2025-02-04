variable "azure_tenant_id" {
  description = "Azure Tenant ID"
}

variable "azure_client_id" {
  description = "Azure Client ID"
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
}

variable "sse_forwarding_profiles" {
  description = "List of the desired forwarding profiles"
  default     = ["m365"]

  validation {
    condition     = alltrue([for i in var.sse_forwarding_profiles : contains(["m365", ], i)]) #Add "internet" to the list once that is supported.
    error_message = "Currently only m365 is supported."
  }
}

variable "sse_bandwidth" {
  description = "The desired bandwidth in Mbps."
  default     = 250

  validation {
    condition     = contains([250, 500, 750, 1000], tonumber(var.sse_bandwidth))
    error_message = "The sse_bandwidth variable must be one of the following values: 250, 500, 750, or 1000."
  }
}

variable "tunnel_subnets" {
  default = [
    "169.254.0.0/30",
    "169.254.0.4/30",
  ]
}

variable "transit_gateway" {
  description = "The Aviatix transit gateway object"

  #Check that transit gatway is passed as the complete object.
  validation {
    condition     = alltrue([for key in ["id", "vpc_id", "account_name"] : contains(keys(var.transit_gateway), key)])
    error_message = "It looks like you did not provide the entire Aviatrix transit gateway object."
  }

  #Check that transit gatway has an AS number configured.
  validation {
    condition     = var.transit_gateway.local_as_number != ""
    error_message = "The Aviatrix transit gateway must have a local_as_number configured."
  }
}

variable "redundancy" {
  description = "Specifies the Device link SKU .The possible values are: noRedundancy, zoneRedundancy."
  default     = "noRedundancy"

  validation {
    condition     = contains(["noRedundancy", "zoneRedundancy"], var.redundancy)
    error_message = "The redundancy variable must be one of the following values: noRedundancy, zoneRedundancy."
  }
}

variable "location" {
  description = "The Azure region where to provision the SSE remote network. E.g. \"East US\"."
  type        = string
}
