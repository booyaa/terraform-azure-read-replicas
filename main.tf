provider "azurerm" {
  version = "=1.32.0"
}

variable "owner" {}
variable "location" {}
variable "admin_login" {}
variable "admin_password" {}

resource "azurerm_resource_group" "demo" {
  name     = "demo"
  location = var.location

  tags = {
    owner = var.owner
  }
}

resource "azurerm_postgresql_server" "demo" {
  name                = "terraform-demo"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  sku {
    name     = "GP_Gen5_2" #  {pricing tier}_{compute generation}_{vCores}
    capacity = 2
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 35
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  version                      = "9.5"
  ssl_enforcement              = "Enabled"

  tags = {
    owner = var.owner
  }
}


