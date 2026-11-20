resource "azurerm_virtual_network" "aks-vnet" {
  name = "aks-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = [ "10.0.0.0/16" ]
}
resource "azurerm_subnet" "aks-subnet1" {
  name = "aks-np-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}
