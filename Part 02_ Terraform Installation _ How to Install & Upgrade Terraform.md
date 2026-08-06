
### How to Install and Configure Terraform?
* Go to "terraform.io", click on install and select the particular way.
* A zip file will be downloaded, which will contain the exe file. This terraform.exe is basically a command line tool, this is not the actual terraform. When we run this terraform command, it will perform different tasks based on the provider and code. This exe is not the complete terraform, this is just command line tool for terraform.
* We have providers based on the cloud, which has different functionality which is actually talking to the cloud. Terraform.exe is not deploying our resources, this is just a command line tool which will basically trigger the provider and the configuration file and perform the task according to the terraform command which we run.
* We have to add the terraform.exe path to the System Environment variable so that we can run the terraform command from anywhere.

### Terraform Version & How to upgrade?
* Run terraform version command to get the version details.
* We have to download the latest version of terraform exe or download any desired version which we want to keep. To upgrade the terraform version, first we have to find where is the exe file kept. We can see the path in the environment variables.
* We have to copy the desired version of terraform exe file and replace it with the existing one in the Environment variable folder.

### Terraform with Visual Studio Code:
* Go to "code.visualstudio.com" and download and install the VSCode.
* Install the "Hashicorp Terraform" Extension from Hashicorp.
* Install the "Azure Terraform" Extension from Microsoft.
* The extensions help in pointing out the error if we don't mention all the required arguments in a resource block or any syntax error. VSCode helps to correct the code, it will highlight the error.
* Click on file, and select "Open in Integrated terminal" and we can run terraform commands directly.
* It is a Microsoft tool, so it is integrated well with the Microsoft products.

