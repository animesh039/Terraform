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
* If we have more than two values to iterate through or more that 2 values are different then we can use nested map like:
``` hcl
variable "nsgs" {
  type = map(any)
  default = {
    nsg1 = {
      location = "westeurope"
      rg = "rg1"
    }
    nsg2 = {
      location = "eastus"
      rg = "rg2"
    }
    nsg3 = {
      location = "westus"
      rg = "rg3"
    }
  }
}
resource "azurerm_network_security_group" "nsgs" {
  for_each = var.nsgs
  name = each.key
  location = each.value["location"]
  resource_group_name = each.value["rg"]
}
```
* Count loop helps in changing the name on the basis of numbers and it iterates on the basis of nunmbers. If only one property of a resource changes, then also we can use for_each loop like below. So, if there is only one value which is changing, we can use a list to iterate through instead of a map.
``` hcl
variable "rgs" {
  type = list(any)
  default = ["rg-prod", "rg-test", "rg-dev"]
}
resource "azurerm_resource_group" "rgs" {
  for_each = toset(var.rgs)
  name = each.value
  location = "westeurope"
}
```

> **NOTE:** If we are iterating through a list of strings, we have to make sure that the values should be unique and in order to make terraform know that the value is unique, we have to convert the list into set and then we can use it in for_each loop.

> **NOTE:** It's better to define the variable values in terraform.tfvars as it will be easy for the person who don't have knowledge of terraform also, to edit the values in the file. It can be used by anyone in the team, so it is a good practise to keep the variables at one place in terraform.tfvars.

3. **for:** It will make the code complex. It is difficult to read as well. But it is useful in some cases where we want to achieve some complex transformation in terraform. For loop is not iterating but it is helping in the transforation of the variable. Example:
``` hcl
variable "nsgs" {
  type = map(any)
  default = {
    nsg1 = {
      location = "westeurope"
      rg = "rg1"
      env = "prd"
    }
    nsg2 = {
      location = "eastus"
      rg = "rg1"
      env = "tst"
    }
    nsg1 = {
      location = "westus"
      rg = "rg1"
      env = "dev"
    }
  }
}
```
* So, I have a requirement thet the env value should be prefixed with a - in the key values. Example: nsg1-prd, nsg2-tst, nsg3-dev. In this case we have to transform the variable using for loop.
``` hcl
variable "nsgs" {
  type = map(any)
  default = {
    nsg1 = {
      location = "westeurope"
      rg = "rg1"
      env = "prd"
    }
    nsg2 = {
      location = "eastus"
      rg = "rg1"
      env = "tst"
    }
    nsg1 = {
      location = "westus"
      rg = "rg1"
      env = "dev"
    }
  }
}

output "nsgs" {
  value = { for k, v in var.nsgs : "${k}-${v.env}" => v }
}
```
* The output will be a map with the transformed keys and values.
* This represents Transformed keys: "${k}-${v.env}"
* There is no transformation in value, so Transformed Value : v

> **NOTE:** If it is not required to use for loop, avoid using it.

* If we want output in the list format, we can use for loop like below:
``` hcl
output "envs" {
  value = [ for k, v in var.nsgs : v.env ]
}
```
* If we want to pick only the prd environment, then:
``` hcl
output "envs" {
  value = [ for k, v in var.nsgs : v.env if v.env == "prd" ]
}
```
* If we want to reverse key and values, then:
``` hcl
output "nsgs" {
  value = { for k, v in var.nsgs : v.rg => k... }
}
```
* "k..." this will activate the grouping mode and it will group the similar values.


### Dynamic Block:
* It is another type of terraform expression.
* There are various resources like "azurerm_route_table" which is having a sub-block "route". So, by using dynamic block we can assign values to sub-block dynamically. We can define multiple routes in the same route_table resource. So, we have to apply looping in routes only i.e. sub-block level and not on the block level which is the resource "azurerm_route_table".
* We have see that we can repeat nested blocks like subnet block in virtual network resource to get multiple subnets in same resource block. We can use dynamic block underneth the resource block to do the iteration of the sub-block.
* The resource block will be executed once and the nested sub-block will be executed multiple times with the help of dynamic block.

``` hcl
locals {
  subnets = {
    subnet1 = "192.168.0.0/24"
    subnet1 = "192.168.1.0/24"
    subnet1 = "192.168.2.0/24"
  }
}
resource "azurerm_virtual_network" "vnet1" {
  name = "vnet1"
  resource_group_name = "rg1"
  location = "westeurope"
  address_space = ["192.168.0.0/16"]

  dynamic "subnet" {
    for_each = local.subnets   --> Loop over
    iterator = item         --> iterator to represent current element (optional), subnet will be default iterator
    content {
      name = item.key                --> Nested block content
      address_prefix = item.value    --> Nested block content
    }
  }
}
```
* Dynamic block always works with for_each, it will not work with count.
* If a nested block or a sub-block is not repeatable then we can't use nested block else it will give error.

* If the nested block is not repeatable and we want to handle the dynamic block based on some user input that the sub-block should be present or not then we can have condition like if the "var.managed_identity_enable" is true the only have the sub-block otherwise don't have the sub-block like below:
``` hcl
resource "azurerm_mssql_server" "sqlserver" {
  name = "sqlserver5474"
  resource_group_name = "rg1"
  location = "westeurope"
  version = "12.0"
  administrator_login = "sqladmin"
  administrator_login_password = "thisIsAmj11"

  dynamic "identity" {
    for_each = var.managed_identity_enable == true ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

variable "managed_identity_enable" {
  type = bool
  description = "Set to true for creating a managed identity in the Azure SQL Server. Default is false."
}
```

* Real Production Example Use Case: We want to add multiple ports to the security rule of NSG and only iterate through the security_rule sub-block.
``` hcl
resource "azurerm_network_security_group" "nsgs" {
  for_each = var.subnets
  name = "nsg-$(each.key)-$(var.environment)-$(var.location_short)-01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  
}
```
