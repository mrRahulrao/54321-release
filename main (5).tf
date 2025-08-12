variable "create" { type = bool }
variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "version" { type = string }
variable "system_pool" {
  type = object({
    name     = string
    count    = number
    vm_size  = string
  })
}
variable "user_pools" {
  type = list(object({
    name     = string
    count    = number
    vm_size  = string
  }))
  default = []
}
variable "aad_enabled" { type = bool }
variable "workload_identity" { type = bool }
variable "tags" { type = map(string) }

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.create ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns"
  kubernetes_version  = var.version

  default_node_pool {
    name       = var.system_pool.name
    node_count = var.system_pool.count
    vm_size    = var.system_pool.vm_size
    mode       = "System"
  }

  identity { type = "SystemAssigned" }

  oidc_issuer_enabled       = var.workload_identity
  workload_identity_enabled = var.workload_identity

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each              = var.create ? { for p in var.user_pools : p.name => p } : {}
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id
  vm_size               = each.value.vm_size
  node_count            = each.value.count
  mode                  = "User"
}
