variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key" { type = string }
variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
  })
}
variable "os_disk_type" { type = string }
variable "os_disk_size_gb" { type = number }
variable "subnet_id" { type = string, default = null }
variable "public_ip" { type = bool, default = false }
variable "data_disks" {
  type    = list(object({ size_gb = number, type = string }))
  default = []
}
variable "tags" { type = map(string) }

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  disable_password_authentication = true
  tags = var.tags
}

resource "azurerm_managed_disk" "data" {
  for_each             = { for i, d in var.data_disks : i => d }
  name                 = "${var.name}-data-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
  for_each          = azurerm_managed_disk.data
  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = each.key
  caching            = "ReadOnly"
}
