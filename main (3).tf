variable "create" { type = bool }
variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "address_space" { type = list(string) }
variable "subnets" {
  type = list(object({ name = string, address_prefix = string }))
}
variable "tags" { type = map(string) }

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "sn" {
  for_each             = var.create ? { for s in var.subnets : s.name => s } : {}
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [each.value.address_prefix]
}
