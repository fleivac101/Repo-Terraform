terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------
# Demo config (change freely)
# -----------------------------
locals {
  # Intentionally "disallowed" region for governance demo
  location = "westus3"

  # Intentionally "disallowed" VM size (GPU / high-cost family)
  vm_size = "Standard_NC6s_v3"

  prefix = "iac-gov-demo"
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.prefix}"
  location = local.location
}

# -----------------------------
# Network
# -----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.prefix}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${local.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# -----------------------------
# Linux VM (policy target)
# -----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = local.vm_size

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_username = "azureuser"

  # For plan-only demo: placeholder key is OK as long as it's syntactically valid.
  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdemoonlydemoonlydemoonlydemoonlydemoonlydemoonly user@demo"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# -----------------------------
# Outputs (handy for demo)
# -----------------------------
output "demo_region" {
  value = azurerm_resource_group.rg.location
}

output "demo_vm_size" {
  value = azurerm_linux_virtual_machine.vm.size
}

