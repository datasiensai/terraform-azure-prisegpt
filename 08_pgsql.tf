resource "azurerm_postgresql_flexible_server" "default" {
  name                   = var.pgsql_server_name
  resource_group_name    = azurerm_resource_group.az_openai_rg.name
  location               = var.location
  version                = var.pgsql_version
  delegated_subnet_id    = azurerm_subnet.pgsql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = var.pgsql_administrator_login
  administrator_password = var.pgsql_administrator_password
  zone                   = "1"
  storage_mb             = var.pgsql_storage_mb
  sku_name               = var.pgsql_sku_name
  backup_retention_days  = var.pgsql_backup_retention_days

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}