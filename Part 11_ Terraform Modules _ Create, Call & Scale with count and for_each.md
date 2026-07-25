### Modules:
* There are two types of modules: Root and Child module. Root module calls child modules.
* All the codes we have discussed so far were root modules.
* Child module is called terraform module.
* One benefit of using module is we can have all the standardization of the module like naming convention to be followed. There will not be any issue while creating the resources as the resources will be created with proper specification which doesn't violate the standard policies defined.
* We can also store the module in git repository and anyone can use.
* Think of module as a code to which we give some input, it creates resources and give us some outputs.

##### Benefits of Modules:
1. Reusability
2. Consistency
3. Scalability
4. Encapsulation: We can encapsulate the whole code in a package and use the code at the organization level as a standard code.
5. Version Control

* Modules are important and always used in Production Environment in Enterprises.

### How to Create a Module:
* Module File Structure:
* modules
  * nsg
      * examples       --> Sample code for Module (Optional)
      * main.tf        --> Source Code/Resource Block for Module.
      * outputs.tf     --> Module Output Value
      * providers.tf   --> Provider for Module
      * readme.md      --> Instructions (Optional)
      * variables.tf   --> Module Input Arguments
* Source code is the module where we write the code, here we define the standardization like naming convention. Source Code is simply the terraform code itself.
* Whenever we are writing a modeule, we should keep in mind that it should be flexible and reusable.
* Module Input Arguments:
   * Fixed Value: It can't be changed at the time of calling the module. Example: nsg in the name of nsg, any fixed deny rule, any fixed route.
   * Inputs: All variables which we are going to use in the modules. Example: component_name, environment, location.
   * Required Input: Inputs which are necessary to provide or pass the value as there is no default value supplied to it in terraform.tfvars file. We have to provide the value when we call the module. Example: component_name. There are required input with specific allowed values like location.
   * Optional Input: We can have a default value for this. If someone is not providing any value, it will take the default value.



##### Code for Module:
1. Create a folder called "modules" and inside that create another folder "nsg".
2. Inside nsg folder create files main.tf, outputs.tf, providers.tf, readme.md, variables.tf and examples folder.

* **main.tf file:**
``` hcl
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-${var.component_name}-${var.environment}-${var.location}-${var.index}"
  location = var.location
  resource_group_name = var.resource_group_name
}
```

* **variables.tf:**
``` hcl
variable "component_name" {
  type = string
}
variable "location" {
  type = string
  validation {
    condition = contains(["centralus", "eastus", "eastus2", "westus"], var.location)
    error_message = "Location not allowed. Valid values are East, West and Central US."
  }
}
variable "environment" {
  type = string
  default = "dev"
}
variable "index" {
  type = number
  default = 1
}
```
* we want to use the nsg ID, so we have to define it in the output.tf.
* **outputs.tf:**
``` hcl
output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}
```
* Module can have it's own provider version. So, we want that whenever anyone is calling this module it should have a particular provider version. So, even if the root module has different provider version, this module will use its own provider version. If provider is not defined in child module, it will inherit from root module.
* **providers.tf:**
``` hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
```

> **NOTE:** On the organization level, we can have standard modules for each resource so that anyone can use it in our project and everyone follows same naming convention, standardization, best practices.

### Project Module:
1. **Resource Group Module:**
* **main.tf:**

* **locals.tf:**
``` hcl
locals {
  tags = merge({
    DeploymentDate = timestamp()
    Environment = var.environment
    Sensitivity = var.environment == "prd" ? "High" : var.environment == "tst" ? "Medium"
  },
  var.tags)     ---> So, if anyone wants more tags it will be merged to tags as a whole.
}
```

* **output.tf:**

* **variables.tf:**
``` hcl
variable "location" {
  description = "location of the Azure Resources."
  type = string
  default = "westeurope"

  validation {
    condition = contains(["westeurope", "northeurope", "eastus", "westus", "centralus"])
    error_message = "Valid values are westeurope or eastus."
  }
}
variable "location_short" {
  description = "Short location of the Azure resources for naming convention."
  type = string
  default = weu
  validation {
    condition = contains(["weu", "neu", "eus", "wus", "cus"], var.location_short)
  }
}
variable "environment" {
  description = "Environment name"
  type = string
  validation {
    condition = contains(["tst", "prd", "sbx", "uat", "dev"], var.environment)
    error_message = "Valid values for environment are tst, prd, sbx, dev or uat."
  }
}
variable "client" {
  type = string
}
```

2. 
* **main.tf:**

* **output.tf:**

* **variables.tf:**


