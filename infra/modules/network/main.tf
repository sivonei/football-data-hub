# main.tf - Network resources for the Football Data Hub
# Creates: VNet, 4 Subnets, NSG, Azure Bastion

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for Azure Bastion - name is mandatory, minimum /26
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/26"]
}

# Subnet for API VMs (VM-1 and VM-2)
resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for monitoring (VM-3: Prometheus + Grafana)
resource "azurerm_subnet" "monitoring" {
  name                 = "subnet-monitoring"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Subnet reserved for future management tools
resource "azurerm_subnet" "management" {
  name                 = "subnet-management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# NSG - firewall rules applied to app and monitoring subnets
resource "azurerm_network_security_group" "main" {
  name                = "${var.project_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # SSH only from Bastion subnet - never directly from internet
  security_rule {
    name                       = "allow-ssh-from-bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/26"
    destination_address_prefix = "*"
  }

  # HTTP from Load Balancer
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

  # FastAPI port from Load Balancer
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

  # Grafana only from internal VNet - never from internet
  security_rule {
    name                       = "allow-grafana-internal"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

# Associate NSG with subnet-app
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Associate NSG with subnet-monitoring
resource "azurerm_subnet_network_security_group_association" "monitoring" {
  subnet_id                 = azurerm_subnet.monitoring.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Public IP for Azure Bastion - static required
resource "azurerm_public_ip" "bastion" {
  name                = "${var.project_name}-bastion-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Bastion Host - secure access to VMs without public IPs
resource "azurerm_bastion_host" "main" {
  name                = "${var.project_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tunneling_enabled   = true
  ip_connect_enabled  = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# Public IP for NAT Gateway - used for outbound internet access from VMs
resource "azurerm_public_ip" "nat" {
  name                = "${var.project_name}-nat-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NAT Gateway - allows VMs without public IPs to access the internet for outbound traffic
# VMs can download packages, Docker images, updates without being directly exposed
resource "azurerm_nat_gateway" "main" {
  name                = "${var.project_name}-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

# Associate public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate NAT Gateway with subnet-app (VM-1 and VM-2)
resource "azurerm_subnet_nat_gateway_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# Associate NAT Gateway with subnet-monitoring (VM-3)
resource "azurerm_subnet_nat_gateway_association" "monitoring" {
  subnet_id      = azurerm_subnet.monitoring.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}