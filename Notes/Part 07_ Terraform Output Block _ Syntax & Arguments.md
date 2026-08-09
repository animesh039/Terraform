
---

### Output Block:
* It is used for generating some output. If we want to expose the ID of resource group or any other attribute, we can generate that using output block of terraform.
* In modules concept it is also used. We can generate the output of a module so that we can consume it into the child module.
* We can use output block to do debugging and validation as well.
* We can also consume the output generated from output block by some powershell or shell script.
* Output block doesn't depend on the provider, so we don't have to mention any provider resource type. We just use the block name only.
* The output will be stored in the output block in terraform state file after terraform apply.
* **value is the mandatory argument**, which is used to generate the required output.

```hcl
data "azurerm_resource_group" "network" {
  name = "network-rg"
}
output "network_rg_id" {
  value = data.azurerm_resource_group.network.id
  description = "Network Resource Group ID"
}
```

### Output Block Optional Arguments:
1. **description:** To provide some description for the output.
2. **depends_on:** We want that some block should be read and then the output should be displayed.
3. **sensitive:** We want that the Network resource ID shouldn't be visible in plain text in the output of terraform plan or apply.

```hcl
data "azurerm_subscription" "current" {
}
data "azurerm_resource_group" "network_rg" {
  name = "network-rg"
}
output "network_rg_id" {
  depends_on = [ data.azurerm_subscription.current ]
  sensitive = true
  value = data.azurerm_resource_group.network_rg.id
  description = "Network Resource Group ID"
}
```
* We can run terraform output command to get the outputs.
* We can use terraform output command and store the value in some powershell script and use it.
### LAB:
1. Create a VM using terraform pipeline and output the IP, username and password. Use these details in ansible script to install Nginx in the VM and deploy a website in the nest stage of the pipeline.
