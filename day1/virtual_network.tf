resource "azurerm_virtual_network" "poc-vn"{
    name = "${var.prefix}-network"
    location = "${var.loc}"
    resource_group_name = azurerm_resource_group.poc-rg.name
    address_space = [ "10.0.0.0/25" ]
}
resource "azurerm_subnet" "poc-sub1" {
    virtual_network_name = azurerm_virtual_network.poc-vn.name
    name = "public-subnet"
    resource_group_name = azurerm_resource_group.poc-rg.name
    address_prefixes = [ "10.0.0.0/26" ]
}
resource "azurerm_subnet" "poc-sub2" {
    virtual_network_name = azurerm_virtual_network.poc-vn.name
    name = "private-subnet"
    resource_group_name = azurerm_resource_group.poc-rg.name
    address_prefixes = [ "10.0.0.64/26" ]
}
resource "azurerm_network_interface" "poc-nic"{
    name = "${var.prefix}-nic"
    location = "${var.loc}"
    resource_group_name = azurerm_resource_group.poc-rg.name
    ip_configuration {
        name = "${var.prefix}-config1"
        subnet_id = azurerm_subnet.poc-sub2.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.poc-pub.id #Even though I choose private subnet doesn't matter it gets the public-ip for vm in azure
    }
}