resource "azurerm_lb" "hut-lb" {
    name = "${var.prefix}-lb"
    resource_group_name = azurerm_resource_group.hut-rg.name
    location = var.loc
    sku = "Standard"
    sku_tier = "Regional"

    frontend_ip_configuration {
        name = azurerm_public_ip.hut-pubip-lb.name
        public_ip_address_id = azurerm_public_ip.hut-pubip-lb.id
    }
}
resource "azurerm_lb_backend_address_pool" "hut-lb-backend" {
  name = "${var.prefix}-lb-bp"
  loadbalancer_id = azurerm_lb.hut-lb.id
}
resource "azurerm_lb_probe" "hut-lb-probe" {
  name = "${var.prefix}-lb-probe"
  loadbalancer_id = azurerm_lb.hut-lb.id
  protocol = "Tcp"
  port = 80
}
resource "azurerm_lb_rule" "hut-lb-rule" {
  name = "${var.prefix}-lb-rule"
  loadbalancer_id = azurerm_lb.hut-lb.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = azurerm_public_ip.hut-pubip-lb.name
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.hut-lb-backend.id]
  probe_id = azurerm_lb_probe.hut-lb-probe.id
}