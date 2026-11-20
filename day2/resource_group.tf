resource "azurerm_resource_group" "hut-rg" {
  name = "${var.prefix}-rg"
  location = var.loc
}