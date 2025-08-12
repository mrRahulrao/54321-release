terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.120" }
  }
}

locals {
  prompt = jsondecode(file("${path.module}/prompt.tfvars.json"))
}

# Example: VNet (created if requested)
module "vnet" {
  source              = "../../modules/vnet"
  create              = try(local.prompt.network.create, false)
  name                = try(local.prompt.network.name, "54321-appraps-${var.location}-vnet")
  location            = var.location
  resource_group_name = try(local.prompt.network.resource_group, "rg-54321-appraps-${terraform.workspace}")
  address_space       = try(local.prompt.network.address_space, ["10.10.0.0/16"])
  subnets             = try(local.prompt.network.subnets, [{ name = "sn-app", address_prefix = "10.10.1.0/24" }])
  tags                = merge(var.tags, { env = terraform.workspace })
}

# Example: Linux VM if requested
module "vm_linux" {
  source              = "../../modules/vm_linux"
  count               = try(local.prompt.vm.count, 0)
  name                = try(local.prompt.vm.name, "vm-app-001")
  location            = var.location
  resource_group_name = try(local.prompt.vm.resource_group, "rg-54321-appraps-${terraform.workspace}")
  vm_size             = try(local.prompt.vm.vm_size, "Standard_E8s_v5")
  admin_username      = try(local.prompt.vm.admin_username, "azureuser")
  ssh_public_key      = try(local.prompt.vm.ssh_public_key, "ssh-ed25519 AAAA...")
  image               = try(local.prompt.vm.image, { publisher = "Canonical", offer = "0001-com-ubuntu-server-jammy", sku = "22_04-lts" })
  os_disk_type        = try(local.prompt.vm.os_disk_type, "Premium_LRS")
  os_disk_size_gb     = try(local.prompt.vm.os_disk_size_gb, 64)
  subnet_id           = try(local.prompt.vm.subnet_id, null)
  public_ip           = try(local.prompt.vm.public_ip, false)
  data_disks          = try(local.prompt.vm.data_disks, [])
  tags                = merge(var.tags, try(local.prompt.vm.tags, {}), { env = terraform.workspace })
}

# Example: AKS if requested
module "aks" {
  source              = "../../modules/aks_cluster"
  create              = try(local.prompt.aks.create, false)
  name                = try(local.prompt.aks.name, "54321-appraps-aks")
  location            = var.location
  resource_group_name = try(local.prompt.aks.resource_group, "rg-54321-appraps-${terraform.workspace}")
  version             = try(local.prompt.aks.version, "1.29")
  system_pool         = try(local.prompt.aks.system_pool, { name = "sys", count = 1, vm_size = "Standard_D4s_v5" })
  user_pools          = try(local.prompt.aks.user_pools, [])
  aad_enabled         = try(local.prompt.aks.aad, true)
  workload_identity   = try(local.prompt.aks.workload_identity, true)
  tags                = merge(var.tags, try(local.prompt.aks.tags, {}), { env = terraform.workspace })
}
