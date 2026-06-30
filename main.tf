data "azurerm_client_config" "current" {}

# --- Landing zone: resource group + network ---------------------------------

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.prefix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.40.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.40.1.0/24"]
}

# --- Observability wired in from day one ------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# --- Cloud-native compute: AKS with a managed identity + Azure RBAC ----------

resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  dns_prefix          = var.prefix
  tags                = var.tags

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  # Identity-first: cluster uses a system-assigned managed identity, and we let
  # Entra ID (Azure AD) back Kubernetes authz via Azure RBAC — the bridge from a
  # classic AD/Entra background to cloud-native auth.
  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  network_profile {
    network_plugin = "azure"
  }
}

# --- Identity-as-code: an Entra ID app + service principal -------------------
# Demonstrates registering a workload identity declaratively — the same identity
# discipline I ran on-prem (AD/Entra), now expressed as Terraform.

resource "azuread_application" "workload" {
  display_name = "app-${var.prefix}-workload"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "workload" {
  client_id = azuread_application.workload.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}
