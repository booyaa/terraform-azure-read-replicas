provider "azurerm" {
  version = "=1.34.0"
}

variable "owner" {}
variable "location" {}
variable "admin_login" {}
variable "admin_password" {}

resource "azurerm_resource_group" "demo" {
    location = "uksouth"
    name     = "demo"
    tags     = {}
}

resource "azurerm_postgresql_server" "demo" {
  name                = "pr1mary-demo"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name

  sku {
    name     = "GP_Gen5_2" #  {pricing tier}_{compute generation/family}_{no of vCores}
    capacity = 2
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
    auto_grow = "Disabled"
  }

  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  version                      = "10"
  ssl_enforcement              = "Enabled"

  tags = {
    owner = var.owner
  }
}

resource "null_resource" "demo" {
  # enables replication on the primary server
  provisioner "local-exec" {
    command = <<ENABLE_REPLICATION
az postgres server configuration set \
  --resource-group ${azurerm_resource_group.demo.name} \
  --server-name ${azurerm_postgresql_server.demo.name} \
  --name azure.replication_support --value REPLICA
ENABLE_REPLICATION
  }

  # restart primary for change to take effect
  provisioner "local-exec" {
    command = <<RESTART_SERVER
az postgres server restart \
  --name ${azurerm_postgresql_server.demo.name} \
  --resource-group ${azurerm_resource_group.demo.name}
RESTART_SERVER
  }

  # create replica
  provisioner "local-exec" {
    command = <<CREATE_REPLICA
az postgres server replica create \
  --name ${azurerm_postgresql_server.demo.name}-replica \
  --source-server ${azurerm_postgresql_server.demo.name} \
  --resource-group ${azurerm_resource_group.demo.name}
CREATE_REPLICA
  }

  depends_on = [azurerm_postgresql_server.demo]
}



