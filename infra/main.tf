# main.tf - Entry point for the Football Data Hub infrastructure
# This file configures the Terraform provider and connects to Azure

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# Configure the Azure provider
# Terraform reads credentials from the Azure CLI login
provider "azurerm" {
  features {}
}

# Resource Group - container for all Azure resources
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
}

# Network module - creates VNet, Subnet and NSG
module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Compute module - creates 3 VMs with static public IPs
module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
}