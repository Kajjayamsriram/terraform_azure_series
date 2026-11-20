resource "azurerm_container_registry" "acr" {
  name = "aksrepodemoop"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Basic"
  admin_enabled = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  skip_service_principal_aad_check = true
}