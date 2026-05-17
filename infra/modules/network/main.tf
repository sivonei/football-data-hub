# main.tf - Network resources for the Football Data Hub
# Creates: VNet, Subnet, and NSG with security rules

# Virtual Network - the private network where all VMs will live
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Address space for the entire VNet
  # 10.0.0.0/16 gives us 65536 addresses to work with
  address_space = ["10.0.0.0/16"]
}

# Subnet - a segment inside the VNet where our VMs will be placed
resource "azurerm_subnet" "main" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name

  # 10.0.1.0/24 gives us 256 addresses inside the VNet
  address_prefixes = ["10.0.1.0/24"]
}

# Network Security Group - the firewall that controls traffic to the VMs
resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow SSH only - used to access VMs for deployment and maintenance
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP traffic - for the API and frontend
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow port 8000 - FastAPI runs on this port
  security_rule {
    name                       = "allow-api"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Grafana - monitoring dashboard runs on port 3000
  security_rule {
    name                       = "allow-grafana"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the Subnet
# This applies the firewall rules to all VMs in the subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}