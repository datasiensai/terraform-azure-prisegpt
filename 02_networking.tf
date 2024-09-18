# Create Solution Virtual Network
resource "azurerm_virtual_network" "az_openai_vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.az_openai_rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Azure Virtual Network Subnets
resource "azurerm_subnet" "az_openai_subnet" {
  resource_group_name                           = azurerm_resource_group.az_openai_rg.name
  virtual_network_name                          = azurerm_virtual_network.az_openai_vnet.name
  name                                          = var.subnet_config.subnet_name
  address_prefixes                              = var.subnet_config.subnet_address_space
  service_endpoints                             = var.subnet_config.service_endpoints
  private_link_service_network_policies_enabled = var.subnet_config.private_link_service_network_policies_enabled
  private_endpoint_network_policies             = var.subnet_config.private_endpoint_network_policies_enabled
  dynamic "delegation" {
    for_each = var.subnet_config.subnets_delegation_settings
    content {
      name = delegation.key
      dynamic "service_delegation" {
        for_each = toset(delegation.value)
        content {
          name    = service_delegation.value.name
          actions = service_delegation.value.actions
        }
      }
    }
  }
}

# New subnet for RAG API
resource "azurerm_subnet" "rag_api_subnet" {
  name                 = var.rag_api_subnet_config.subnet_name
  resource_group_name  = azurerm_resource_group.az_openai_rg.name
  virtual_network_name = azurerm_virtual_network.az_openai_vnet.name
  address_prefixes     = var.rag_api_subnet_config.subnet_address_space
}

# New delegated subnet for PostgreSQL database
resource "azurerm_subnet" "pgsql_subnet" {
  name                 = "pgsql-subnet"
  resource_group_name  = azurerm_resource_group.az_openai_rg.name
  virtual_network_name = azurerm_virtual_network.az_openai_vnet.name
  address_prefixes     = ["10.4.0.0/16"]  # Adjust this as needed

  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Add a private DNS zone
resource "azurerm_private_dns_zone" "default" {
  name                = "${var.pgsql_server_name}.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.az_openai_rg.name
}

# Link the private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${var.pgsql_server_name}-pdz-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.az_openai_vnet.id
  resource_group_name   = azurerm_resource_group.az_openai_rg.name
}

# Add a private DNS zone for RAG API
resource "azurerm_private_dns_zone" "rag_api" {
  name                = var.rag_api_dns_zone_name
  resource_group_name = azurerm_resource_group.az_openai_rg.name
}

# Link the RAG API private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "rag_api" {
  name                  = "${var.rag_api_app_name}-pdz-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.rag_api.name
  virtual_network_id    = azurerm_virtual_network.az_openai_vnet.id
  resource_group_name   = azurerm_resource_group.az_openai_rg.name
  registration_enabled  = true
}

# Add A record for RAG API
resource "azurerm_private_dns_a_record" "rag_api" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.rag_api.name
  resource_group_name = azurerm_resource_group.az_openai_rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.rag_api_app.static_ip_address]

  depends_on = [azurerm_container_app_environment.rag_api_app]
}
