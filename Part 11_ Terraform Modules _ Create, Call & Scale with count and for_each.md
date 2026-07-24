### Modules:
* There are two types of modules: Root and Child module. Root module calls child modules.
* All the codes we have discussed so far were root modules.
* Child module is called terraform module.
* One benefit of using module is we can have all the standardization of the module like naming convention to be followed. There will not be any issue while creating the resources as the resources will be created with proper specification which doesn't violate the standard policies defined.
* We can also store the module in git repository and anyone can use.

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
* Source code is the module where we write the code, here we define the standardization like naming convention. Source Code is simply the terraform code.
* 
