### Advanced Terraform Commands:
### Terraform Providers:
* It is used to get output of the providers.
* If we are using different providers in different modules and different provider in root module. If we want to list the providers which are being used in the whole code then we can get the list of those providers and their versions with the help of terraform providers command.
``` bash
terraform providers
```

### Terraform Version:
* It will give terraform tool version and if there is any latest version available.
* It will also show the provider version from the main code.
``` bash
terraform version
```

### Terraform Taint & Untaint:
* Terraform taint command is used to taint our resource.
* Sometimes a reource gets failed in the azure portal during the deployment or we want to re-deploy a resource due to some reason. So, instead of deleting the resources from azure portal and running the terraform command again we can re-deploy the resources from terraform by taint the resource.
``` bash
terraform taint azurerm_resource_group.test-rg
```
* After tainting the resource, if we run the terraform plan again we can see that the resource will be re-deployed in next terraform apply. It is showing that it will be replaced.

* If we tainted a resource by mistake then we can untaint it using terraform command which is opposite to taint command:
``` bash
terraform untaint azurerm_resource_group.test-rg
```
* After untainting, if we run terraform plan we can see that there are no changes in the infrastructure.

> **NOTE:** Once the resource is re-deployed using terraform apply command after the tainiting of it. We can't restore it to the old one.

* To taint a resource which is inside a module:
``` bash
terraform taint module.test_backend_nsg.azurerm_network_security_group.nsg
```
