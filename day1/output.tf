output "public-ip"{
    value = azurerm_public_ip.poc-pub.ip_address
}