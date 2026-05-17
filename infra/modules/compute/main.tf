# main.tf - Compute resources for the Football Data Hub
# Creates: 3 VMs with static public IPs and network interfaces

# ─── VM-1: API + Redis primary ───────────────────────────────────────────────

# Public IP for VM-1 - static so it doesn't change when VM is stopped
resource "azurerm_public_ip" "vm1" {
  name                = "${var.project_name}-vm1-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network interface for VM-1 - connects the VM to the subnet
resource "azurerm_network_interface" "vm1" {
  name                = "${var.project_name}-vm1-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
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

  # SSH key authentication - more secure than password
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS - stable and widely supported
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# ─── VM-2: API + Redis replica ────────────────────────────────────────────────

resource "azurerm_public_ip" "vm2" {
  name                = "${var.project_name}-vm2-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm2" {
  name                = "${var.project_name}-vm2-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2.id
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

# ─── VM-3: Prometheus + Grafana ───────────────────────────────────────────────

resource "azurerm_public_ip" "vm3" {
  name                = "${var.project_name}-vm3-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm3" {
  name                = "${var.project_name}-vm3-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm3.id
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