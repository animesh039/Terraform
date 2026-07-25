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
##### Child Module:
1. **Resource Group Module:**
* **main.tf:**
``` hcl
resource "azurerm_resource_group" "rg" {
  name = "rg-${var.client}-${var.environment}-${var.location_short}-01"
  location = var.location
  tags = local.tags

  lifecycle {
    ignore_changes = [tags["deploymentDate"]]
  }
}
```
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
``` hcl
output "resource_group" {  --> All the RG values we can take from this output block later
  value = azurerm_resource_group.rg
}
# If we think that there are some sensitive values which can't be exposed in output, then we can use individually.
#output "resource_group_name" {
#  value = azurerm_resource_group.rg.name
#}
#output "resource_group_location" {
#  value = azurerm_resource_group.rg.location
#}
```

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
variable "tags" {    --> optional
  type = map(any)
  default = {}   --> dafault is kept empty so that it will atleast have those tags mentioned earlier.
}
```

2. **Subnet Module:**
* **main.tf:**
``` hcl
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  name = "snet-${each.key}-${var.environment}-${var.location_short}-01"
  resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes = each.value.address_prefixes
}
resource "azurerm_network_security_group" "nsg" {
  for_each = var.subnets
  name = "nsg-${each.key}-${var.environment}-${var.location_short}-01"
  location = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.allowed_ports
    iterator = port
    content {
      name = "AllowPort-${port.value}"
      priority = 200 + index(each.value.allowed_ports, port.value)
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = port.value
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  }
# We are adding a default custom rule to deny all traffic above the already define rules. 4096 is the last priority number for defining the custom rule.
  security_rule {
      name = "DenyAll-Custom"
      priority = 4096
      direction = "Inbound"
      access = "Deny"
      protocol = "*"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix = "*"
      destination_address_prefix = "*"
    }
  tags = local.tags
    lifecycle {
      ignore_changes = [tags["DeploymentDate"]]
     }
}
```
* **output.tf:**
``` hcl
output "subnet" {
  value = azurerm_subnet.subnets
}
```

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
variable "tags" {
  type = map(any)
  default = {}
}
variable "virtual_network_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnets" {
  type = map(any)
}
```

### Calling a Module:
* We call the child module from the root module.
* Modeule Sources:
   * Local: "./modules/resource_group"
   * Hashicorp: "Azure/vnet/azurerm"    ( also supports version argument in Module Block)
   * Git Http: "git::https://example.com/vpn.git"
   * Git Ssh: "git::ssh://username@example.com/storage.git"
   * GitHub: "github.com/hashicorp/example"

``` hcl
module "rg" {
  source = "./modules/resource_group"
  component_name = "backend"
  environment = "test"
  location = "eastus"
}
module "nsg" {
  source = "./modules/nsg"
  count = 5

  component_name = "backend"
  environment = "test"
  index = count.index
  location = module.rg.rg_location
  resource_group_name = module.rg.rg_name
}
```
##### Main Code/Root Module:
* **main.tf:**
``` hcl
module "rg" {
  source = "../modules/resource_group"
  environment = var.environment
  client = var.client
  location = var.location
  location_short = var.location_short
  tags = {
    module = "testing"
  }
}
```

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
variable "tags" {
  type = map(any)
  default = {}
}
variable "virtual_network_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "subnets" {
  type = map(any)
}
```

* **terraform.tfvars:**
``` hcl
location = "westeurope"
location_short = "weu"
client = "azt"
environment = "tst"
vnet_address_space = ["172.18.0.0/24"]
db_subnet = ["172.18.0.0/28"]
be_subnet = ["172.18.0.16/28"]
fe_subnet = ["172.18.0.48/28"]

databases = {
  app = {
    max_size_gb = 10
    sku_name = "S0"
  }
  nlog = {
    max_size_gb = 2
    sku_name = "Basic"
  }
}

subnets = {
  db = {
    address_prefixes = ["172.18.0.0/28"]
    allowed_ports = ["1433"]
  }
  be = {
    address_prefixes = ["172.18.0.16/28"]
    allowed_ports = ["443", "80"]
  }
  fe = {
    address_prefixes = ["172.18.0.48/28"]
    allowed_ports = ["443", "80"]
  }
}

app_services = {

}
```

* **network.tf:**
``` hcl
resource "azurerm_virtual_network" "vnet" {
  name = "vnet-azt-${var.environment}-${var.location_short}-01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = var.vnet_address_space
}

module "subnets" {
  source = "../modules/subnet"

  environment = var.environment
  location = var.location
  location_short = var.location_short
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = module.rg.resource_group.name
  subnets = var.subnets
}
```

* **compute.tf:**
``` hcl
resource "azurerm_service_plan" "asp" {
  name = "asp-azt-${var.environment}-${var.location_short}-01"
  resource_group_name = module.rg.resource_group.name
  location = module.rg.resource_group.location
  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app_services" {
  for_each = var.app_services
  name = "app-azt-${each.key}-${var.environment}-${var.location_short}-01"
  resource_group_name = module.rg.resource_group.name
  location = module.rg.resource_group.location
  service_plan_id = azurerm_service_plan.asp.id
  app_settings = { for k, v in each.value.app_settings :
    upper("${var.environment}_${k}") ==> v
  }

  site_config {}
}
```
