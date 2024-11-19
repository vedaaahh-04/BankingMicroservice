provider "azurerm" {
  features {}
  subscription_id = "f0cd788c-53b3-41f5-81cc-20af7ed52814"
}

# Resource Group
resource "azurerm_resource_group" "gr" {
  name     = "gr-S2"
  location = "Canada Central"
}
 
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-S2"
  address_space       = ["192.168.0.0/19"]
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name
}
 
# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-S2"
  resource_group_name  = azurerm_resource_group.gr.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}
 
# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-S2"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name
}
 
# Public IP Address
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name
  allocation_method   = "Static"  # Changed to Static as required by Standard SKU
  sku                  = "Standard"  # Specifying the Standard SKU for public IP
  domain_name_label   = "myvm-public-ip"  # Optional: This will create a DNS name for the public IP
}
 
 
# Network Interface for Linux VM
resource "azurerm_network_interface" "nic_linux" {
  name                = "nic-linux-vm"
  location            = azurerm_resource_group.gr.location
  resource_group_name = azurerm_resource_group.gr.name
 
  ip_configuration {
    name                          = "ipconfig-linux"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id  # Associate Public IP
  }
}
 
# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "linux-vm"
  resource_group_name             = azurerm_resource_group.gr.name
  location                        = azurerm_resource_group.gr.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "Password@123" # Replace with secure credentials
  disable_password_authentication = false
 
  network_interface_ids = [azurerm_network_interface.nic_linux.id]
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "solvedevops1643693563360"
    offer     = "rocky-linux-9"
    sku       = "plan001"
    version   = "latest"
  }
 
  plan {
    name      = "plan001"
    publisher = "solvedevops1643693563360"
    product   = "rocky-linux-9"
  }
 
  custom_data = base64encode(file("user-data.sh"))
}
 
# Output Public IP Address
output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
 
 
