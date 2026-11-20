resource "azurerm_virtual_network" "hut-nw"{
    name = "${var.prefix}-net1"
    resource_group_name = azurerm_resource_group.hut-rg.name
    location = var.loc
    address_space = [ "10.0.0.0/16" ]
}
resource "azurerm_subnet" "hut-sub1" {
  name = "subnet1"
  resource_group_name = azurerm_resource_group.hut-rg.name
  virtual_network_name = azurerm_virtual_network.hut-nw.name
  address_prefixes = [ "10.0.0.0/25" ]
}
resource "azurerm_subnet" "hut-sub2" {
  name = "subnet2"
  resource_group_name = azurerm_resource_group.hut-rg.name
  virtual_network_name = azurerm_virtual_network.hut-nw.name
  address_prefixes = [ "10.0.0.128/25" ]
}
