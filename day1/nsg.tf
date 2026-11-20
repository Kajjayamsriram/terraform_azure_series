resource "azurerm_network_security_group" "nsg" {
  name = "${var.prefix}-01"
  resource_group_name = azurerm_resource_group.poc-rg.name
  location = "${var.loc}"
}

resource "azurerm_network_security_rule" "poc-nsr" {
  name = "${var.prefix}-01"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.poc-rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#Missed the assocation caused ssh connection failure
resource "azurerm_network_interface_security_group_association" "poc_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.poc-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}