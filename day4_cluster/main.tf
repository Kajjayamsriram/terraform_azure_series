resource "azurerm_resource_group" "rg" {
  name     = "aks-rg-dev"
  location = "East US 2"
}
data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name = "aks-cluster-dev"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  dns_prefix = "aksclusterdev"
  sku_tier = "Free"
  kubernetes_version = "1.36.2"

  #Upgrades
  automatic_upgrade_channel = "patch" #K8s software updates
  node_os_upgrade_channel   = "NodeImage" #patches the underlying host operating system
  
  #Security Feature Add-Ons
  local_account_disabled    = true # not share admin kubeconfig; Entra ID only auth
  run_command_enabled       = false
  oidc_issuer_enabled       = true # needed for workload identity
  workload_identity_enabled = true # pods get Azure access without stored secrets
  azure_policy_enabled      = true
  #image_cleaner_enabled     = true

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2als_v6"
    os_disk_size_gb = 30
    vnet_subnet_id = azurerm_subnet.aks-subnet1.id
    orchestrator_version = "1.33" #skew policy allows n-3 for nodepool kubernetesVersion
    upgrade_settings {
      max_surge = "10%"
    }
  }
  node_provisioning_profile {
    mode = "Manual"
    default_node_pools = "None" #Karpenter-based Node Auto-Provisioning by AKS 
  }

  azure_active_directory_role_based_access_control {
    tenant_id = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
    #admin_group_object_ids = [""] #entra group to grant cluster-admin access
  }
  #cluster perms to create azure resources
  identity {
    type = "SystemAssigned"
  }

  #Secret Plugin
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  #Network Plugins
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"


    service_cidr = "10.11.0.0/16" #default is 10.0.0.0/16 to avoid overlap with vnet
    dns_service_ip = "10.11.0.7" # must be inside service_cidr for Coredns Pod
    pod_cidr = "10.21.0.0/16"
  }
  #Storage Plugins
  storage_profile {
    disk_driver_enabled         = true  # Default creates Azure Managed Disks for PVCs
    file_driver_enabled         = true  # Default mounts Azure Files shares
    snapshot_controller_enabled = true  # Default enables volume snapshots
    blob_driver_enabled         = false # if mounting Blob storage? enable
  }
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+05:30"
  }
  
  lifecycle {
    ignore_changes = [
      kubernetes_version, 
      default_node_pool[0].node_count, 
      default_node_pool[0].orchestrator_version
    ]
  }
}

#Grant deploying user cluster-admin through Azure RBAC
resource "azurerm_role_assignment" "cluster-admin" {
  scope = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "network" {
  scope = azurerm_virtual_network.aks-vnet.id
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
}

output "aks_principal" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
output "created_user_object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "kube_config_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

#Azure externsions are only used for flux, daiper etc., as basic addons comes during cluster creation ex: coredns, kube-system..
#Where as AWS needs addons for every cluster component coredns,eks-pod-identity-agent to ebs, lb for pod usage.

#service_cidr is the pool of IPs for Services inside the cluster.
#pod_cidr is the pool of IPs for pods inside the cluster.
#dns_service_ip is one fixed IP from the service pool, used by the clusters DNS. coredns
#These set separate IP ranges for Services and Pods inside the cluster so nothing overlaps. EKS chooses them automatically, while AKS needs them set manually if the defaults conflict with our VNet.