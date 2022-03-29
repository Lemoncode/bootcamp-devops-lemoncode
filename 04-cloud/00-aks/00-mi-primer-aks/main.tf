provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "Lemoncode-Terraform"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "aks-lemoncode-tf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "aks-lemoncode-tf"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}
