resource "azurerm_public_ip" "hut-pubip-lb" {
  name = "${var.prefix}-lb"
  location = var.loc
  resource_group_name = azurerm_resource_group.hut-rg.name
  allocation_method = "Static"
}