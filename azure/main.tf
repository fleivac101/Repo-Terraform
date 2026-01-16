resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-test"
  location = "westus3"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-test"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # NO public_ip_address_id => NO IP publica
  }
}

variable "ssh_public_key" { type = string }

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-test"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size           = "Standard_B2ats_v2"
  admin_username = "azureuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
