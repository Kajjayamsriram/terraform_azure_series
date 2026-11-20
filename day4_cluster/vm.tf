resource "azurerm_public_ip" "name" {
  name = "linuxvm-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Static"
  sku = "Standard"
}
resource "azurerm_network_interface" "name" {
  name = "linux-vm-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.aks-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.name.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "linux-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2als_v6"
  admin_username = "sriram"
  os_disk {
    name = "linux-vm-disk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 30
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version   = "latest"
  }
  admin_ssh_key {
    username = "sriram"
    public_key = file("~/.ssh/dev_key.pub")
  }
  #To enable a System-Assigned Managed Identity
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [azurerm_network_interface.name.id]
}
#Perms
data "azurerm_subscription" "current" {}
data "azurerm_role_definition" "Contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "name" {
  scope = data.azurerm_subscription.current.id
  role_definition_id = data.azurerm_role_definition.Contributor.id
  principal_id = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
#vm to cluster access
resource "azurerm_role_assignment" "aks_cluster_user" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
resource "azurerm_role_assignment" "aks_rbac" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

output "vm_principal" {
    value = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
output "role_definition"{
    value = data.azurerm_role_definition.Contributor.name
}

#Add Nsg Rules for 22