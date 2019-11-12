provider "azurerm" {
}
variable "TAG" {
    type = "string"
}
variable "AZURE_USERNAME_REG" {
    type = "string"
}
variable "AZURE_PASSWORD_REG" {
    type = "string"
}
variable "AZURE_SERVER_REG" {
    type = "string"
}

resource "azurerm_resource_group" "rg" {
        name = "mareak.fitec.webscrap.rg"
        location = "eastus"
}

resource "azurerm_container_group" "cg" {
  name                = "mareak.fitec.webscrap.cg"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  ip_address_type     = "public"
  dns_name_label      = "webscrapping"
  os_type             = "Linux"
  
  image_registry_credential {
	username          = "${var.AZURE_USERNAME_REG}"
    password          = "${var.AZURE_PASSWORD_REG}"
    server            = "${var.AZURE_SERVER_REG}"
  }

  container {
    name   = "webscrapping"
    image  = "mareackr.azurecr.io/webscrapping_webscrapping:${var.TAG}"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }
}
