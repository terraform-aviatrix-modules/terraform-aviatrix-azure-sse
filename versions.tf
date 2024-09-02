terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = ">=3.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
    random = {
      source = "hashicorp/random"
    }
    time = {
      source = "hashicorp/time"
    }
  }
  required_version = ">= 1.0"
}
