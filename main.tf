terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test-rg" {
  name     = "cloud-shell-storage-centralindia"
  location = "Central India"
}

resource "azurerm_container_registry" "test-acr" {
  name                = "testingcontainer"
  sku                 = "Basic"
  resource_group_name = azurerm_resource_group.test-rg.name
  location            = azurerm_resource_group.test-rg.location
}

resource "azurerm_kubernetes_cluster" "testk8cluster" {
  name                = "testk8cluster"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  dns_prefix          = "testk8cluster-dns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }
}

resource "azurerm_role_assignment" "enablePulling" {
  principal_id                     = azurerm_kubernetes_cluster.testk8cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.test-acr.id
  skip_service_principal_aad_check = true
}
