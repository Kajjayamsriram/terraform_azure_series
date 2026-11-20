resource "azurerm_network_security_group" "hut-nsg" {
  name = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.hut-rg.name
  location = var.loc
}

resource "azurerm_network_security_rule" "hut-nsg-rule" {
    name = "${var.prefix}-nsg-rule"
    resource_group_name = azurerm_resource_group.hut-rg.name
    priority = 200
    network_security_group_name = azurerm_network_security_group.hut-nsg.name
    direction = "Inbound"
    protocol = "Tcp"
    access  = "Allow"
    source_port_range = "*"
    destination_port_range = "80" 
    source_address_prefix = "*"
    destination_address_prefix = "*"
}
resource "azurerm_network_security_rule" "hut-nsg-rule2" {
    name = "${var.prefix}-nsg-rule2"
    resource_group_name = azurerm_resource_group.hut-rg.name
    priority = 220
    network_security_group_name = azurerm_network_security_group.hut-nsg.name
    direction = "Inbound"
    protocol = "Tcp"
    access  = "Allow"
    source_port_range = "*"
    destination_port_range = "80" 
    source_address_prefix = "AzureLoadBalancer"
    destination_address_prefix = "*"
}