# Create an Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "default" {
  name                   = var.pgsql_server_name
  resource_group_name    = azurerm_resource_group.az_openai_rg.name
  location               = var.location
  version                = var.pgsql_version
  delegated_subnet_id    = azurerm_subnet.pgsql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = var.pgsql_administrator_login
  administrator_password = random_password.pgsql_password.result
  zone                   = "1"
  storage_mb             = var.pgsql_storage_mb
  sku_name               = var.pgsql_sku_name
  backup_retention_days  = var.pgsql_backup_retention_days

  # Explicitly disable public network access for security
  public_network_access_enabled = false

  # Ensure the private DNS zone link is created before the PostgreSQL server
  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

# Configure PostgreSQL server extensions
resource "azurerm_postgresql_flexible_server_configuration" "default" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = join(",", var.database_extensions)
}

# Generate a random password for the PostgreSQL admin user
resource "random_password" "pgsql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the PostgreSQL admin password in Azure Key Vault
resource "azurerm_key_vault_secret" "pgsql_password" {
  name         = "pgsql-admin-password"
  value        = random_password.pgsql_password.result
  key_vault_id = azurerm_key_vault.az_openai_kv.id

  # Ensure the Key Vault role assignment is created before storing the secret
  depends_on = [
    azurerm_role_assignment.kv_role_assigment
  ]
}
