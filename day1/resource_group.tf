resource "azurerm_resource_group" "poc-rg"{
    name = "${var.prefix}-rg"
    location = "${var.loc}"
}