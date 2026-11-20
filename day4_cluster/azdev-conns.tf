resource "azuredevops_project" "example" {
  name               = "docker-app"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
  description        = "Created from Terraform"
  features = {
    boards       = "enabled"
    repositories = "enabled"
    pipelines    = "enabled"
    testplans = "disabled"
    artifacts = "disabled"
  }
}
#Acr Perms
# data "azuredevops_project" "proj"{
#   name = "demo-first-project"
# }
resource "azuread_application_registration" "app" {
  display_name = "sp-azdev-acr"
}
resource "azuread_service_principal" "sp" {
  client_id = azuread_application_registration.app.client_id
}
resource "time_rotating" "example" {
  rotation_days = 5
}
resource "azuread_application_password" "name" {
  application_id = azuread_application_registration.app.id
  display_name = "azdev-acr"
  #end_date = "2160h"
  rotate_when_changed = {
    rotation = time_rotating.example.id
  }
}
resource "azurerm_role_assignment" "acr" {
  scope = azurerm_container_registry.acr.id
  principal_id = azuread_service_principal.sp.object_id
  role_definition_name = "AcrPush"
}
resource "azuredevops_serviceendpoint_dockerregistry" "acr" {
  project_id = azuredevops_project.example.id
  service_endpoint_name = "acr-connection"
  docker_registry = "https://${azurerm_container_registry.acr.login_server}"
  docker_username= azuread_application_registration.app.client_id
  docker_password = azuread_application_password.name.value
  registry_type = "Others"
}

#Aks Perms
resource "azuread_application_registration" "app1" {
  display_name = "sp-azdev-aks"
}
resource "azuread_service_principal" "sp1" {
  client_id = azuread_application_registration.app1.client_id

}
resource "time_rotating" "name" {
  rotation_days = 5
}
resource "azuread_application_password" "pass2" {
  application_id = azuread_application_registration.app1.id
  display_name = "azdev-aks"
  #end_date = "2160h"
  rotate_when_changed = {
    rotation = time_rotating.name.id
  }
}
#authentication like az aks get-credentials 
resource "azurerm_role_assignment" "aks_user" {
  principal_id = azuread_service_principal.sp1.object_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  scope = azurerm_kubernetes_cluster.aks.id
}
#authorization to deploy resources within namespace level
resource "azurerm_role_assignment" "aks_writer" {
  scope = azurerm_kubernetes_cluster.aks.id
  principal_id = azuread_service_principal.sp1.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
}
resource "azuredevops_serviceendpoint_azurerm" "arm" {
  project_id = azuredevops_project.example.id
  service_endpoint_name = "arm-connection"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  azurerm_spn_tenantid = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id = data.azurerm_client_config.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
  credentials {
    serviceprincipalid = azuread_service_principal.sp1.client_id
    serviceprincipalkey = azuread_application_password.pass2.value
  }
}