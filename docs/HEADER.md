# terraform-aviatrix-azure-sse

### Description
This module facilitates easy integration between Aviatrix and Microsoft's Security Service Edge.

As Azure's Terraform provider currently does not yet support the creation of the Security Services Edge resources, this module depends on directly calling the Azure API.

> [!WARNING]
>Be aware as of the date of publishing this module, the Microsoft Graph API v1.0 does not yet support the remote network API's, as they are in preview. This module uses the beta version of the graph API, which may be subject to change.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.0.0 | >=1.3 | >= 7.0 | >= 3.0.0