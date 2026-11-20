resource "azurerm_linux_virtual_machine_scale_set" "hut-vmss"{
  resource_group_name = azurerm_resource_group.hut-rg.name
  name = "${var.prefix}-vmss"
  location = var.loc
  sku = "Standard_D2nls_v6"
  instances = 2
  zones = ["1", "2"]

  admin_username = "sriram"
  disable_password_authentication = true 

  admin_ssh_key {
      username   = "sriram"
      public_key = file("~/.ssh/dev_key.pub")
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }
  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
    disk_size_gb = 30
  }
  network_interface {
    name = "${var.prefix}-nic"
    primary = true
    network_security_group_id = azurerm_network_security_group.hut-nsg.id
    ip_configuration {
        name = "${var.prefix}-internal"
        primary   = true
        subnet_id = azurerm_subnet.hut-sub1.id
        load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.hut-lb-backend.id ]
    }
  }
  custom_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y nginx
  sudo systemctl enable --now nginx
  sudo echo "Hello from Azure VMSS" > /var/www/html/index.html
  EOF
  )
  upgrade_mode = "Manual"
}
