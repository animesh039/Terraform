### Functions:
1. **timestamp():** to get the current time. We can check the output as:
``` hcl
output "time" {
  value = timestamp()
}
```
* Its use case it to get the time when a resource was created. Azure doesn't provide the creation timestamp, it does but we have to check the activity logs and if we have not configured log analytics workspace, then this logs will also go in 90days. So, we can put a tag in the resource which can give the resource creation timestamp.
``` hcl
resource "azurerm_resource_group" "rg1" {
  name = "resource_group1"
  location = "westeurope"
  tags = {
    createdOn = timestamp()
  }
}
```

2. **try():** There are situation when we try to get and use some property of a resource, but if that property doesn't exist then it will give error like:
``` hcl
locals {
  subnets = {
    subnet1 = "192.168.0.0/24"
    subnet2 = "192.168.1.0/24"
  }
}
output "subnet" {
  value = local.subnets.subnet3
}
```
* So, to handle this type of error we can write like if the value of subnet3 is not available then use the value of subnet1 like:
``` hcl
locals {
  subnets = {
    subnet1 = "192.168.0.0/24"
    subnet2 = "192.168.1.0/24"
  }
}
output "subnet" {
  value = try(local.subnets.subnet3, local.subnets.subnet1)
}
```
3. **coalesce():** There can be some values which are null but we don't want those values. So, with the help of this function we can make sure that only the values which are not null is taken into consideration.
``` hcl
locals {
  subnets = {
    subnet1 = null
    subnet2 = null
    subnet3 = "192.168.2.0/24"
  }
}
output "subnet" {
  value = coalesce(local.subnets.subnet1, local.subnets.subnet2, local.subnets.subnet3)
}
```
4. **merge():** This is specifically for the map variable. We can merge two map variables using this function.
``` hcl
locals {
  subnets = {
    subnet1 = "192.168.0.0/24"
    subnet2 = "192.168.1.0/24"
    subnet3 = "192.168.2.0/24"
  }
  subnets_new = {
    subnet4 = "192.168.3.0/24"
  }
}
output "subnet" {
  value = merge(local.subnets, local.subnets_new)
}
```
5. **lookup():** This is specifically for the map variable which is used to check if a specific key is available in the map variable.
``` hcl
locals {
  subnets = {
    subnet1 = "192.168.0.0/24"
    subnet2 = "192.168.1.0/24"
    subnet3 = "192.168.2.0/24"
  }
}
output "subnet" {
  value = lookup(local.subnets, "subnet3")
}
```

### Conditional Expressions:
* **SYNTAX: condition ? true_value : false_value**
``` hcl
locals {
  a = 100
  b = 200
  c = 200
}
output "fact_check" {
  value = local.a == local.b ? "Hurrayyy!!" : "Ohh no.. :("
}
output "fact_check" {
  value = local.b == local.c ? "Hurrayyy!!" : "Ohh no.. :("
}
```
* Use case: If we want that Prod should be tagged as sensitive environment and others should be tagged as Medium. It is if-else statement as below:

``` hcl
locals {
  tags = {
    DeploymentDate = timestamp()
    Environment = var.environment
    Sensitivity = var.environment == "prd" ? "High" : var.environment == "tst" ? "Medium"
  }
}
```
> **NOTE:** If we will apply the code on existing environment then it will try to overite the resources. So, to test what will return in the values we can use terraform console to test the output. It will drop us in console prompt and we can test the value which will be returned is fine or not.

``` bash
> terraform console
> local.tags
```

### Looping in Terraform:
##### Types of Loop:
1. **Count:**
* Since the iteration is like the list so count will start from 0, we have to add 1 in order to start from 1.
``` hcl
resource "azurerm_resource_group" "rgs" {
  count = 3
  name = "resource_group_${count.index + 1}"
  location = "westeurope"
}
```
* If we want to create NSG in resource group1, then:
``` hcl
resource "azurerm_resource_group" "rgs" {
  count = 3
  name = "resource_group_${count.index + 1}"
  location = "westeurope"
}
resource "azurerm_network_security_group" "nsg1" {
  name = "nsg1"
  location = "westeurope"
  resource_group_name = azurerm_resource_group.rgs[0].name
}
```
* Conditional Expression with Count Loop:
``` hcl
variable "i_want_new_rg" {
  type = bool
}
resource "azurerm_resource_group" "rg1" {
  count = var.i_want_new_rg == true ? 1 : 0
  name = "resource_group_1"
  location = "westeurope"
}
```
* Use Case: Create a database if it is test environment and don't create any database for other environments.
* **NOTE:** If we want to check if only a particular resource will get created or not, then we can use --target option in terraform command. We can check what will be the impact of the changes in code for a particular resource.
``` bash
terraform plan --target=azurerm_mysql_database.nglog_db
```
> **NOTE:** If the naming convention of the resource property is getting changed and not like 1,2,3 then we can use for_each loop.


2. **for_each:** If multiple properties of a resource is changing then we can use this loop.
* It can be used in map, where we can have map as a variable. We can assign uniquie values as a key and can have the values assigned to the key. We can iterate on this variable.
``` hcl
variable "rgs" {
  type = map(any)
  default = {
    resource_group1="westeurope"
    resource_group2="eastus"
    resource_group3="westus"
  }
}
resource "azurerm_resource_group" "rgs" {
  for_each = var.rgs
  name = each.key
  location = each.value
}
```

3. 

