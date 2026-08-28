module "resource_group" {
  source              = "./modules/azurerm_resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "virtual_network" {
  source               = "./modules/azurerm_virtual_network"
  virtual_network_name = var.virtual_network_name
  location             = module.resource_group.output_resource_group_location
  resource_group_name  = module.resource_group.output_resource_group_name
  # public_ip_address_id  = module.public_ip.output_public_ip_id
}

module "subnet" {
  source               = "./modules/azurerm_subnet"
  subnet_name          = var.subnet_name
  resource_group_name  = module.resource_group.output_resource_group_name
  virtual_network_name = module.virtual_network.output_virtual_network_name
}

module "network_interface" {
  source                 = "./modules/azurerm_network_interface"
  network_interface_name = var.network_interface_name
  location               = module.resource_group.output_resource_group_location
  resource_group_name    = module.resource_group.output_resource_group_name
  private_ip_name        = var.private_ip_name
  subnet_id              = module.subnet.output_subnet_id
  public_ip_address_id   = module.public_ip.output_public_ip_address_id
}

module "public_ip" {
  source              = "./modules/public_ip"
  public_ip_name      = var.public_ip_name
  resource_group_name = module.resource_group.output_resource_group_name
  location            = module.resource_group.output_resource_group_location
}

module "virtual_machine" {
  source               = "./modules/azurerm_virtual_machine"
  virtual_machine_name = var.virtual_machine_name
  resource_group_name  = module.resource_group.output_resource_group_name
  location             = module.resource_group.output_resource_group_location
  virtual_machine_size = var.virtual_machine_size
  network_interface_id = module.network_interface.output_network_interface_id
}

module "network_security_group" {
  source                      = "./modules/azurerm_network_security_group"
  network_security_group_name = var.network_security_group_name
  location                    = module.resource_group.output_resource_group_location
  resource_group_name         = module.resource_group.output_resource_group_name
  subnet_id                   = module.subnet.output_subnet_id
}