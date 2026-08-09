
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

---

### Resource Block Meta-Arguments:
* We saw that there are arguments which depends on the provider resource type which is mandatory to provide.
* Meta-Arguments are special arguments if we want to perform some special task on the resource.

1. **Lifecycle:** It is a special sub-block in the resource block. With lifecycle we have multiple flags or multiple arguments which we can use to perform special task on that particular resource block.
```hcl
resource "azurerm_resource_group" "rg1" {
  name = "resource_group1"
  location = "westeurope"
  lifecycle {
    argument = "value"
  }
}
```

* Arguments of lifecycle meta arguments:
    * **create_before_destroy:** When we are changing some property of a resource which doesn't support in-place update, then the default behaviour of terraform is to destroy the resource fist and then create the new one. But in some cases we son't want terraform to follow this, we want terraform should create the resource first and then destroy. Use: create_before_destroy = true, in the argument of lifecycle sub-block.

    * **prevent_destroy:** It helps us to prevent a resource to be accidently deleted. Example: we don't want anyone to delete the database VM, then we can use: prevent_destroy = true, in the argument of lifecycle sub-block. If we want to delete the resource, then first we have to remove the lifecycle meta-argument and then apply.
    * ```hcl
      resource "azurerm_resource_group" "rg1" {
      name = "resource_group2"
      location = "westeurope"
      lifecycle {
        prevent_destroy = true
      }
    }
  ```
   
    * **ignore_changes:** Lets assume, we have a tag in the resource to capture the resource creation timestamp. If we apply the terraform again, it will update the timestamp again with the latest time. We want that this tag of the resource should not be updated. Only once when we are creating the resource, it should be applied and on the next apply this value shouldn't change.
    * ```hcl
      resource "azurerm_resource_group" "rg1" {
      name = "resource_group1"
      location = "westeurope"
      tags = {
        created_on = timestamp()
      }
      lifecycle {
        ignore_changes = [ tags["created_on"] ]
      }
    }
  ```
   
    * **replace_triggered_by:** If we are creating 2 resources, RG and NSG and if we want that if any changes are there in RG, it should automatically replace the NSG as well.
    * ```hcl
      resource "azurerm_resource_group" "rg1" {
        name = "resource_group1"
        location = "westeurope"
      }
      resource "azurerm_network_security_group" "nsg" {
        name = "subnet-1-nsg"
        resource_group_name = azurerm_resource_group.rg1.name
        location = azurerm_resource_group.rg1.location
        lifecycle {
          replace_triggered_by = [ azurerm_resource_group.rg1]
        }
      }
      ```
   
    * **precondition:** This is the condition being checked before creating the resource, even before planning also. Example: We want that the NSG is only created when the name of the subnet is "subnet-1".
    * ```hcl
      resource "azurerm_subnet" "subnet1" {
        name = "subnet-1"
        resource_group_name = "network-rg"
        address_prefixes = ["192.168.0.0/24"]
        virtual_network_name = "vnet1"
      }
      resource "azurerm_network_security_group" "nsg" {
        name = "subnet-1-nsg"
        resource_group_name = "network-rg"
        location = "westeurope"
        lifecycle {
          precondition {
            condition = azurerm_subnet.subnet1.name == "subnet-1"
            error_message = "Subnet name should be subnet-1 only."
          }
        }
      }
      ```
   
    * **postcondition:** This is the condition being checked after the resource is created. Terraform plan will succeed but apply will fail.
    * ```hcl
      resource "azurerm_network_security_group" "nsg" {
        name = "subnet-1-nsg"
        resource_group_name = "network-rg"
        location = "westeurope"
        lifecycle {
          postcondition {
            condition = length(self.security_rule) > 0
            error_message = "The NSG must contain atleast one rule."
          }
        }
      }
      ```

2. 

