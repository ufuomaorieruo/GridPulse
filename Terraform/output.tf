output "resource_group_name" {
  description = "Name of the GridPulse resource group"
  value       = azurerm_resource_group.gridpulse.name
}

output "acr_login_server" {
  description = "Login server for the GridPulse container registry"
  value       = azurerm_container_registry.gridpulse.login_server
}

output "aks_cluster_name" {
  description = "Name of the GridPulse AKS cluster"
  value       = azurerm_kubernetes_cluster.gridpulse.name
}

output "aks_cluster_fqdn" {
  description = "Fully qualified domain name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.gridpulse.fqdn
}