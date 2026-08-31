terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "nous"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "arti-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "this" {
  name                 = "arti-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "arti-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "tls_private_key" "vm_admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "arti-vm"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.this.name
  size                            = "Standard_B2ats_v2"
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = "azureadmin"
    public_key = tls_private_key.vm_admin.public_key_openssh
  }

  os_disk {
    name                 = "arti-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
