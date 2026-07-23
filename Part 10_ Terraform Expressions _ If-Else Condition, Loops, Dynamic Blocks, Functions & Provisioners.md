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
