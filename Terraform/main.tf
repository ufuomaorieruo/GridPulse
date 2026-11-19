
resource "azurerm_resource_group" "gridpulse" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "gridpulse" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.gridpulse.location
  resource_group_name = azurerm_resource_group.gridpulse.name
}

resource "azurerm_subnet" "aks" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.gridpulse.name
  virtual_network_name = azurerm_virtual_network.gridpulse.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "gridpulse-aks-identity"
  location            = azurerm_resource_group.gridpulse.location
  resource_group_name = azurerm_resource_group.gridpulse.name
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_container_registry" "gridpulse" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.gridpulse.name
  location            = azurerm_resource_group.gridpulse.location
  sku                 = "Basic"
  admin_enabled       = false
}

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
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.gridpulse.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.gridpulse.kubelet_identity[0].object_id
}