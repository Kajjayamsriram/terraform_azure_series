resource "azurerm_virtual_machine" "poc-vm" {
    name = "${var.prefix}-vm01"
    location = "${var.loc}"
    resource_group_name = azurerm_resource_group.poc-rg.name
    network_interface_ids = [azurerm_network_interface.poc-nic.id]
    vm_size = "Standard_D2nls_v6"
    delete_os_disk_on_termination = true #auto delete with VM
    storage_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }
    storage_os_disk {
        name = "${var.prefix}-disk1"
        create_option = "FromImage"
        caching = "ReadWrite"
        managed_disk_type = "StandardSSD_LRS"
        disk_size_gb = 30
    }
    os_profile {
      computer_name = "prodvm"
      admin_password = "Password!123"
      admin_username = "sriram"
    }
    tags = {
      environment = "develop"
      application = "poc"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}