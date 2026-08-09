
---

### Data Sources:
* The purpose of Data source is to manage the resources which was not deployed through the terraform.
* We can reference the existing resources using data source which was not deployed through terraform.
* We are reading the data of the resources which we deployed either manually or Powershell. We don't want to manage those resources but want to consume those resources with the new resources which we are going to create through terraform. With the help of data source we can read those resources, and those resources can be integrated to the new resources which we are going to create using resource block.
* Example: We don't want to create keyvault secret using terraform as it will be in plain text format. Instead we want to create it manually and consume it to create username and password of a VM.

```hcl
data "azurerm_key_vault" "amjkv1" {
  name = "amjkeyvault1"
  resource_group_name = "management-rg"
}
```
* Mention the arguments by which we can uniquely identify the resource. These arguments of data block are also mentioned in the Terraform Documentation.

### Data Source References:
```hcl
data "azurerm_resource_group" "network" {
  name = "network-rg"
}
resource "azurerm_network_security_group" "nsg" {
  name = "network-security-group-1"
  location = data.azurerm_resource_group.network.location
  resource_group_name = data.azurerm_resource_group.network.name
}
```
