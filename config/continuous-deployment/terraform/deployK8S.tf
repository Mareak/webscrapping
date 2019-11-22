provider "azurerm" {
} 

resource "azurerm_resource_group" "test" {
  name     = "mareak.k8s.clusterRG"
  location = "East US"
}

resource "azurerm_public_ip" "pip1" {
  name                = "k8s-pip1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "MC_mareak.k8s.clusterRG_clusterfitec_eastus"
  domain_name_label = "mareakp2"
  allocation_method   = "Static"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "clusterfitec"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  dns_prefix          = "clusterfitec"

  agent_pool_profile {
    name            = "agent001"
    count           = 1
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  agent_pool_profile {
    name            = "agent002"
    count           = 1
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "adf7097a-399e-45b5-96fe-ad5f34d461e4"
    client_secret = "e9b6c625-bab5-4854-bcd5-1df23a410900"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.test.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.test.kube_config_raw}"
}

