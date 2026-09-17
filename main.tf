
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

resource "azurerm_resource_group" "artizent" {

  name     = "artizent"
  location = var.location

}

resource "azurerm_virtual_network" "artizent" {

  name                = "artizent-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.artizent.name
  address_space       = ["10.0.0.0/16"]

}

resource "azurerm_subnet" "artizent" {

  name                 = "artizent-subnet"
  resource_group_name  = azurerm_resource_group.artizent.name
  virtual_network_name = azurerm_virtual_network.artizent.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "artizent" {

  name                = "artizent-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.artizent.name

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.artizent.id
    private_ip_address_allocation = "Dynamic"

  }

}

resource "tls_private_key" "artizent_vm_admin" {

  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "azurerm_linux_virtual_machine" "artizent" {

  name                            = "nous"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.artizent.name
  size                            = "Standard_B2ats_v2"
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.artizent.id]

  admin_ssh_key {

    username   = "azureadmin"
    public_key = tls_private_key.artizent_vm_admin.public_key_openssh

  }

  os_disk {

    name                 = "nous-osdisk"
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