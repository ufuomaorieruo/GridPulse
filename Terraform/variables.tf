variable "resource_group_name" {
  description = "Name of the GridPulse Azure Resource Group"
  type        = string
  default     = "gridpulse-rg"
}
variable "location" {
  description = "Azure region for GridPulse infrastructure"
  type        = string
  default     = "South Africa North"
}
variable "acr_name" {
  description = "Name of the GridPulse Azure Container Registry"
  type        = string
  default     = "gridpulseacr"
}
variable "aks_name" {
  description = "Name of the GridPulse AKS cluster"
  type        = string
  default     = "gridpulse-aks"
}
variable "node_count" {
  description = "Number of nodes in the AKS system node pool"
  type        = number
  default     = 1
}
variable "node_vm_size" {
  description = "VM size for the AKS node pool"
  type        = string
  default     = "Standard_D2s_v4"
}
variable "vnet_name" {
  description = "Name of the GridPulse Virtual Network"
  type        = string
  default     = "gridpulse-vnet"
}
variable "subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "aks-subnet"
}
variable "vnet_address_space" {
  description = "Address space for the GridPulse VNet"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_address_prefix" {
  description = "Address range for the AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}
variable "aks_dns_prefix" {
  description = "DNS prefix for the GridPulse AKS cluster"
  type        = string
  default     = "gridpulse-aks-dns"
}