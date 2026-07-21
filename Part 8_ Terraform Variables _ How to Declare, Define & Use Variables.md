### Variable Declaration:

* Variable is important to define for code reusability. 
* Example: In enterprises, we have to create resources in Prod and DR sites at different locations, so we can't change the values everywhere instead we can declare and use variable for this case.

> If we have not given a default value to the variable while defining or we have not given its value anywhere else, then terraform prompt to ask the value of variable.
> 
> If we are not defining any value in terraform or skipping it, then it will take the default value.
``` hcl
variable "location" {
  description = "The Azure Region where the Resource should be created."
  default = "westeurope"
  type = string

}
```

> If we want that default value should be empty then we can pass null value to it.
variable "vm_license_type" {
  type = string
  default = null
}


> Type is optional argument, so if we don't define it. Terraform will take the type of variable by itself based on the value.
>
> If we are explicitly defining the type and not sure about the type of value it can take, then we can mention as any and terraform will assume the type by itself.

``` hcl
variable "tags" {
  description = "A mapping of tags to be assigned to the resource."
  type = map(any)
}
```


> We want that when a value is assigned to a variable, it should be validated first based on some condition and then it should be assigned. There should not be any value which is not valid.
>
> Example: Location should have correct location value passed and not some random value which Azure doesn't support.
``` hcl
variable "location" {
  description = "The Azure Region where the Resource should be created."
  default = "westeurope"
  type = string
  validation {
    condition = contains(["westeurope", "uksouth"], var.location)
    error_message = "Incorrect value, valid values are westeurope and uksouth."
  }
}
```

> When sensitive is true, the value of the variable will be hidden in the plan and apply outputs.
``` hcl
variable "vm_admin_username" {
  description = "Specifies the name of the local administrator account."
  type = string
  sensitive = true
}
```

> If we want that, there should always be a value for some variable. Then we can define to make it as not nullable by:
>
>  In this example, we know that there shoud be some value for username and it should not be empty.
``` hcl
variable "vm_admin_username" {
  description = "Specifies the name of the local administrator account."
  type = string
  nullable = false
}
```

### Variable Definition:
 1. **default:**
``` hcl
variable "location" {
  description = "The Azure Region where the Resource should be created."
  default = "westeurope"
  type = string
}
```

 2. **-var:** We can use -var to define the value of variable while running terraform commands.
``` hcl
variable "location" {
  description = "The Azure Region where the Resource should be created."
  type = string
}
variable "sku" {
  description = "SKU type for Azure app service."
  type = string
}
```
``` bash
terraform plan -var=location="westeurope" -var=sku="S1"
```

> **NOTE:** If we want to take the value from some script then we can use -var but it is not a good option to use within the terraform as we have to mention -var multiple times while writing the command, instead we can use .tfvars file.

 3. **.tfvars file:** default variable definition file for terraform.
``` hcl
location = "westeurope"
```

> **NOTE:** We can have different .tfvars file for test and prod environments and can use the same variable. But at the time of running terraform commands we have to supply the terraform file as:

``` bash
terraform plan -var-file='prod.tfvars' --> In powershell environments
terraform plan -var-file="prod.tfvars" --> In Linux terminal environments
```

> **NOTE:** If the name is terraform.tfvars then we don't have to mentionn with -var-file. If the file name is other than this then we have to explicitly mention it while running terraform commands.

 4. **Environment Variable:** We can define environmet variable and consume it. But how does terraform know which environment variable to take as the variable value. For this terraform follows a particular naming convention. It should start with "TF_VAR_" as a prefix to the variable.
``` bash
$env:TF_VAR_location="westeurope"  --> In powershell
set TF_VAR_location="westeurope"   --> In Command Prompt
export TF_VAR_location="westeurope" --> In Linux
```

 5. **At Runtime:**
``` bash
terraform plan -var=location="westeurope" -var=sku="S1"
```


### Variable Definition Precedence: 
* Highest precedence at the top and lowest at the bottom.
  1. -var or -var-file
  2. *.auto.tfvars or *.auto.tfvars.json
  3. terraform.tfvars.json
  4. terraform.tfvars
  5. environment variable
  6. default



### Variable Usage:

* Create **terraform.tfars** file:
``` hcl
location="westeurope"
```

* Create **main.tf** file:
``` hcl
resource "azurerm_resource_group" "rg-nw" {
  name = "rg-network"
  location = var.location
}
```

### Variable Usage - Interpolation:
* It is used when we want to append a variable with some prefix or suffix or add two values.
* Create **terraform.tfars** file:
``` hcl
nw_resource_group_name = "network"
environment = "test"
```

* Create **main.tf** file:
``` hcl
resource "azurerm_resource_group" "rg-nw" {
  name = "rg-${var.environment}-${var.nw_resource_group_name}"   # --> String interpolation
  location = "westeurope"
}
```

### Local Variable:
