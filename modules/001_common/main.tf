terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.19.1"
    }
  }
} 

#####
# resource_group
#####
resource "azurerm_resource_group" "rg-aro-tf-001" {
  name     = "rg-aro-tf-001"
  location = "japaneast"
}

resource "azurerm_resource_group" "rg-vm-tf-001" {
  name     = "rg-vm-tf-001"
  location = "japaneast"
}

#####
# vnet
#####
resource "azurerm_virtual_network" "vnet-aro-tf-001" {
  name                = "vnet-aro-tf-001"
  resource_group_name = azurerm_resource_group.rg-aro-tf-001.name
  address_space       = ["10.6.0.0/16"]
  location            = azurerm_resource_group.rg-aro-tf-001.location
}

resource "azurerm_virtual_network" "vnet-vm-tf-001" {
  name                = "vnet-vm-tf-001"
  resource_group_name = azurerm_resource_group.rg-vm-tf-001.name
  address_space       = ["10.7.0.0/16"]
  location            = azurerm_resource_group.rg-vm-tf-001.location
}

#####
# subnet
#####
resource "azurerm_subnet" "subnet-aromaster-tf-001" {
  name                 = "subnet-aromaster-tf-001"
  resource_group_name  = azurerm_resource_group.rg-aro-tf-001.name
  virtual_network_name = azurerm_virtual_network.vnet-aro-tf-001.name
  address_prefixes     = ["10.6.0.0/23"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "subnet-aroworker-tf-001" {
  name                 = "subnet-aroworker-tf-001"
  resource_group_name  = azurerm_resource_group.rg-aro-tf-001.name
  virtual_network_name = azurerm_virtual_network.vnet-aro-tf-001.name
  address_prefixes     = ["10.6.2.0/23"]
  service_endpoints = ["Microsoft.ContainerRegistry"]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "subnet-vm-tf-001" {
  name                 = "subnet-vm-tf-001"
  resource_group_name  = azurerm_resource_group.rg-vm-tf-001.name
  virtual_network_name = azurerm_virtual_network.vnet-vm-tf-001.name
  address_prefixes     = ["10.7.0.0/24"]
  service_endpoints = []
  private_link_service_network_policies_enabled = false
}

###
# NSG
###
resource "azurerm_network_security_group" "nsg-vm-tf-001" {
  name                = "nsg-vm-tf-001"
  location            = azurerm_resource_group.rg-vm-tf-001.location
  resource_group_name = azurerm_resource_group.rg-vm-tf-001.name

  dynamic "security_rule" {
    for_each = local.nsg-vm-tf-001.security_rule

    content {
      name                         = security_rule.value[0]
      priority                     = security_rule.value[1]
      direction                    = security_rule.value[2]
      access                       = security_rule.value[3]
      protocol                     = security_rule.value[4]
      source_port_range            = security_rule.value[5]
      destination_port_range       = security_rule.value[6]
      source_address_prefix        = security_rule.value[7]
      destination_address_prefix   = security_rule.value[8]
    }
  }
}