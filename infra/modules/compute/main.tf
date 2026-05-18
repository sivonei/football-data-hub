# main.tf - Compute resources for the Football Data Hub
# Creates: 3 VMs without public IPs, access only via Azure Bastion

# ─── VM-1: API + Redis primary (subnet-app) ──────────────────────────────────

# Network interface for VM-1 - no public IP, private only
resource "azurerm_network_interface" "vm1" {
  name                = "${var.project_name}-vm1-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_app_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }
}

# VM-1 - runs API FastAPI + Redis primary
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "${var.project_name}-vm1"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.vm1.id]

  # SSH key authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# ─── VM-2: API + Redis replica (subnet-app) ───────────────────────────────────

resource "azurerm_network_interface" "vm2" {
  name                = "${var.project_name}-vm2-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_app_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "${var.project_name}-vm2"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.vm2.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
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

# ─── VM-3: Prometheus + Grafana (subnet-monitoring) ───────────────────────────

resource "azurerm_network_interface" "vm3" {
  name                = "${var.project_name}-vm3-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_monitoring_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
  }
}

resource "azurerm_linux_virtual_machine" "vm3" {
  name                = "${var.project_name}-vm3"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.vm3.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
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