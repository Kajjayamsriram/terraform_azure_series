resource "azurerm_public_ip" "poc-pub"{
    name = "${var.prefix}-ip"
    resource_group_name = azurerm_resource_group.poc-rg.name
    location = "${var.loc}"
    allocation_method = "Static"
}