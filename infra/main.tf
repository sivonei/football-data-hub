# main.tf - Entry point for the Football Data Hub infrastructure
# This file configures the Terraform provider and connects to Azure

terraform {
  # Minimum Terraform version required
  required_version = ">= 1.5.0"

  required_providers {
    # Azure provider - allows Terraform to manage Azure resources
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# Configure the Azure provider
# Terraform reads credentials from the Azure CLI login we did earlier
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