
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

variable "coder_version" {
  default = "0.13.6"
}

# Change this password away from the default if you are doing
# anything more than a testing stack.
variable "db_password" {
  default = "coder"
}

###############################################################
# K8s configuration
###############################################################
# Set ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "coder" {
  name     = "coder-resources"
  location = "Central US"
}

resource "azurerm_kubernetes_cluster" "coder" {
  name                = "coder-k8s-cluster"
  location            = azurerm_resource_group.coder.location
  resource_group_name = azurerm_resource_group.coder.name
  dns_prefix          = "coder-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_d2_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.coder.kube_config.0.host
  username               = azurerm_kubernetes_cluster.coder.kube_config.0.username
  password               = azurerm_kubernetes_cluster.coder.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "coder_namespace" {
  metadata {
    name = "coder"
  }
}

###############################################################
# Coder configuration
###############################################################
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.coder.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.coder.kube_config.0.cluster_ca_certificate)
  }
}

resource "kubernetes_role_binding" "coder_binding" {
  metadata {
    name = "coder-binding"
  }

  subject {
    kind      = "ServiceAccount" # Change to "ServiceAccount" if 'coder' is a service account.
    name      = "coder"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = "coder" # This should match the name of the Role you have defined.
    api_group = "rbac.authorization.k8s.io"
  }
}
