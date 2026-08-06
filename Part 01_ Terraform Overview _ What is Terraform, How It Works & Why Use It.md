
---

### What is Terraform (IAC) ?
* Whenever we talk about IT Infrastructure, what comes in our mind is servers, storage, network devices. This Infra basically helps us to host our websites, to run our applications. So, this is basically our IT Infra.
* To deploy or to create or manage this Infra, there were several ways to do this. Before IAC, we were deploying the Infra services either through GUI portal or the scripting language like power shell, shell scripting. But as now we have IAC in place, so we can deploy, create, maintain our Infra in the form of code.

### Why Terraform ?
* IAC is totally different than scripting, we can use IAC to build and maintain our Infra. Specially when we are talking about the cloud, we can deploy, maintain, create our resources in cloud with the help of IAC.
* If we have any application or website, we know that there is an application code. We are writing the code in such a way that they will perform or execute certain task and based on that the application is working. Similarly in the IAC, we can write the code to deploy, maintain, create the Infra. So, this code is called IAC. On top of that there is application code which is hosting the website.
* So, now-a-days with the help of IAC we can have everything as a form of code.
* Terraform is one of the IAC tool.

### Benefits of Terraform:
* It's multi cloud.
* The IAC code is written in Hashicorp Terraform language, which is human readable and very easy.
* Before actually executing the code, we can execute the plan to see what exactly that code is going to do. We can prevent accidental changes in our Infra, as we are checking the changes that our code in perform in Cloud Infra.

### How does Terraform work ?
* Assume there is a bunch of users writing the terraform code in .tf files.
* Next step is, we will run the plan command to check what will be the changes. It's similar to dry run.
* Next, we have to review the plan step, whether there is any un-expected changes in the Infra which is not intended to be made. We will go in the code and make necessary changes in the terraform code, do the planning again and then review.
* If the plan looks good, then we will apply the changes. When we apply the changes, it will be actually deployed in the cloud environments.

### Ways to deploy resources in Azure Cloud:
1. Azure Portal: We can just login to the portal and deploy the resources manually.
2. Azure PowerShell: We can use powershell as an scripting language.
3. Azure CLI: This is Microsoft's own tool to deploy the resources.

###### Then why Terraform? What make terraform different from these?
* We have terraform configuration files in which we write the terraform code. As soon as we apply the changes, first it will write the terraform state file. Terraform state file is the record of changes which we are going to apply with the help of terraform code. At the same time it will deploy the resources in the Azure portal.
* This terraform state file will have all the record set of our configuration file and our actual resources. Terraform state file is called soul of terraform because state file has the sync between the configuration file and the actual resources deployed.
* Terraform State File = Terraform Code + Azure Resources Information
* Every resource has its own resource ID, the configuration of the resource and its properties, all these information terraform state file stores in it. And at the same time it has the terraform configuration file thumbprint. So, basically it is syncing the configuration file with the Azure. When we are applying the terraform code it is deploying the resources and at the same time it will maintain the state file.

* Assume a scenario where we are deploying the resource group with the help of power shell script. If we execute the same code again, it will give error as we are trying to create the same resource again which will not be allowed in Azure as two resources can't be of same name. If we want to deploy VM in that RG with the help of power shell, we have to get that resource group in a variable and then deploy the VM using that variable under the RG using powershell. But if we use terraform code to deploy the RG, it will deploy it and if we rerun the terraform command to create resource again, it will not give error rather it will show that the RG is already present and there are no changes as there is no difference in the code. The code is in sync with the actual environment.
* If we apply the terraform code, it will go to the state file and check if we have the record of that particular resource already existing, it will get the ID of resource and go to Azure portal to check if that particular resource is present. If the resource is available, then it will show no changes. If we want to deploy VM in the RG then we don't have to store it in some variable, simply we have to reference it to the RG already created.
* In Scripting language the IAC code is not in sync with the actual environment but in terraform it is in sync with the help of terraform state file.
* Powershell is working in an Imperative way whereas terraform works in a Declarative way.

###### Terraform Syntax:
* The files in which we are writing the code is called terraform configuration files and the extension should be .tf
* .tfvars file is used to assign the value to a variable. If the file name is other than terraform.tfvars, then we have to explicitly specify the variable file at the time of running the command.
* Terraform code is always written in block format.
* Syntax:
``` hcl
resource "azurerm_resource_group" "rg" {
  name = "resource-group-1"
  location = "westeurope"
}
```
  * resource --> Block Types, this can be resource block, data block, output block etc.
  * azurerm_resource_group -- > Provider Resource
  * rg --> Block Name, which is used to refer the resource in other blocks.
  * name = "resource-group-1"  --> Arguments, this is something we can find in the terraform documentation of Azure.
  * We can put a hash for single-line comment, ending at the end of the line.
  * /* Multi-Line Comment -
    Start and end delimiters for a
    comment that might span
    over multiple lines*/


