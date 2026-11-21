
# ==================================================
# GRIDPULSE - AZURE INFRASTRUCTURE
# ==================================================

# 1. Resource Group
resource "azurerm_resource_group" "gridpulse" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Virtual Network
resource "azurerm_virtual_network" "gridpulse" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.gridpulse.location
  resource_group_name = azurerm_resource_group.gridpulse.name
}

# 3. AKS Subnet
resource "azurerm_subnet" "aks" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.gridpulse.name
  virtual_network_name = azurerm_virtual_network.gridpulse.name
  address_prefixes     = [var.subnet_address_prefix]
}

# 4. User-Assigned Managed Identity
resource "azurerm_user_assigned_identity" "aks" {
  name                = "gridpulse-aks-identity"
  location            = azurerm_resource_group.gridpulse.location
  resource_group_name = azurerm_resource_group.gridpulse.name
}

# 5. Network Contributor Role Assignment
resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# 6. Azure Container Registry
resource "azurerm_container_registry" "gridpulse" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.gridpulse.name
  location            = azurerm_resource_group.gridpulse.location
  sku                 = "Basic"
  admin_enabled       = false
}

# 7. Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "gridpulse" {
  name                = var.aks_name
  location            = azurerm_resource_group.gridpulse.location
  resource_group_name = azurerm_resource_group.gridpulse.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name           = "systempool"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.1.0.0/16"
    dns_service_ip      = "10.1.0.10"
    outbound_type       = "loadBalancer"
  }

  depends_on = [
    azurerm_role_assignment.aks_network
  ]
}

# 8. AcrPull Role for AKS Kubelet Identity
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.gridpulse.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.gridpulse.kubelet_identity[0].object_id
}

# 9. GitHub Actions - Contributor Role
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = azurerm_resource_group.gridpulse.id
  role_definition_name = "Contributor"
  principal_id         = var.github_actions_principal_id
  principal_type       = "ServicePrincipal"
}

# 10. GitHub Actions - ACR Push Role
resource "azurerm_role_assignment" "github_actions_acr_push" {
  scope                = azurerm_container_registry.gridpulse.id
  role_definition_name = "AcrPush"
  principal_id         = var.github_actions_principal_id
  principal_type       = "ServicePrincipal"
}

# 11. GitHub Actions - AKS Cluster User Role
resource "azurerm_role_assignment" "github_actions_aks_user" {
  scope = replace(
    azurerm_kubernetes_cluster.gridpulse.id,
    "resourceGroups",
    "resourcegroups"
  )

  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.github_actions_principal_id
  principal_type       = "ServicePrincipal"
}
