
---

### Resource Block:
* Resource block is the only block which is responsible for creating/deleting the resources in Azure portal.
* Each resource will have a specific type which we have to use for creating the resource. It is fixed and comes with provider itself, so can't be changed.
* Some argument is required in the resource block which we have to mention otherwise it will give error.

```hcl
resource "azurerm_route_table" "route1" {
  name = "route-table1"
  location = "westeurope"
  resource_group_name = "terraform-rg"
  route {                                --> Sub-Block
    name = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type = "VnetLocal"
  }
}
```

### Resource Block Behaviour:
* **Create:** Create resources that exist in the configuration but are not associated with a real infrastructure object in the state.
* **Destroy:** Destroy resources that exist in the state but no longer exist in the configuration.
* **Update in-place:** Resources whose arguments have changed and supports in-place update. The resources which support in-place update will only be changed like size of VM. If it doesn't support in-place update then it will destroy and re-create the resource.
* **Destroy and Recreate:** Resources whose arguments have changed but which can't be updated in-place due to remote API limitations. Example: if we change the location of a resource which doesn't support in-place update, then it will re-create the resource.

> **NOTE:** We can always go to google for terraform documantation like "terraform azure virtual network" and use the configuration from here. We should always refer the documentation for any new changes or arguments.

###### Creation:
``` hcl
resource "azurerm_resource_group" "rg-hub" {
  name = "rg-azt-hub-ue2-01"
  location = "westeurope"
}
```
###### Update:
``` hcl
resource "azurerm_resource_group" "rg-hub" {
  name = "rg-azt-hub-ue2-01"
  location = "westeurope"
  tags = {
    "DeploymentDate" = "14052025"
  }
}
```
###### Destroy:
```bash
terraform destroy
```
###### Destroy and Re-Create:
``` hcl
resource "azurerm_resource_group" "rg-hub" {
  name = "rg-azt-hub-ue2-01"
  location = "eastus"
  tags = {
    "DeploymentDate" = "14052025"
  }
}
```

---

### Resource Block Dependencies:
##### Parallel Execution:
* This is one of the benefit of terraform. If we are deploying the resources which are not dependent on each other, then terraform deploys those resources parallely. Example: Deploying 3 resource group.

##### Implicit Dependency:
* With the implicit dependency we can define the dependency of one resource on the other.
* Writing the code up and down doesn't decide the dependency of the resources, as by default terraform will execute the code parallely in random fashion and not sequential execution.
* Example: Creation of NSG and RG. Terraform will try to create the NSG in parallel to RG and it will fail as RG should be present for NSG to be created in it.
```hcl
resource "azurerm_resource_group" "rg" {
  name = "network-rg"
  location = "westeurope"
}
resource "azurerm_network_security_group" "nsg" {
  name = "network_security_group1"
  resource_group_name = azurerm_resource_group.rg.name
  location  = azurerm_resource_group.rg.location
}
```
* We are referring one property of the resource to the another one.


##### Explicit Dependency:
* What if we don't have the same property in two resources, in this case we can't refer one resource to another because we are not using the same property in the second resource from the first one. But we know that the first resource should be created and then the second one. In this case how we can decide the dependency. For that purpose we are using explicit dependency.
* Example: we are creating subnet and NSG and we know that they can be created independently, but we want to make sure that the subnet should be created first and the NSG should be created.
```hcl
resource "azurerm_subnet" "subnet1" {
  name = "subnet-1"
  resource_group_name = "network-rg"
  address_prefixes = ["192.168.0.0/24"]
  virtual_network_name = "vnet1"
}
resource "azurerm_network_security_group" "nsg" {
  depends_on = [azurerm_subnet.subnet1]
  name = "subnet-1-nsg"
  resource_group_name = "network-rg"
  location = "westeurope"
}
```
* NSG depends on the Subnet block to be created, by referring to the subnet block.
* We are explicitly referring the other block, we are instructing terraform explicitly to wait for the creation of subnet and then create NSG.



