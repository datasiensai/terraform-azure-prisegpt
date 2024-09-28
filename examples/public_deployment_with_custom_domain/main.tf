terraform {
  #backend "azurerm" {}
  #backend "local" { path = "terraform-example1.tfstate" }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# #################################################
# # PRE-REQS                                      #
# #################################################
### Random integer to generate unique names
resource "random_integer" "number" {
  min = 0001
  max = 9999
}

module "private-chatgpt-openai" {
  source  = "git@github.com:bijucyborg/tf-private-azure-chatgpt"
  #version = "~> 2.2.0"

  # 01 common + RG #
  #================#
  location            = var.location
  tags                = var.tags
  resource_group_name = var.resource_group_name

  # 02 networking #
  #===============#
  virtual_network_name = "${var.virtual_network_name}${random_integer.number.result}"
  vnet_address_space   = var.vnet_address_space
  subnet_config        = var.subnet_config
  

  # 03 keyvault (Solution Secrets)
  #==============================#
  kv_name                  = "${var.kv_name}${random_integer.number.result}"
  kv_sku                   = var.kv_sku
  kv_fw_default_action     = var.kv_fw_default_action
  kv_fw_bypass             = var.kv_fw_bypass
  kv_fw_allowed_ips        = var.kv_fw_allowed_ips
  kv_fw_network_subnet_ids = var.kv_fw_network_subnet_ids

  # 04 openai service
  #==================#
  oai_account_name                       = "${var.oai_account_name}${random_integer.number.result}"
  oai_sku_name                           = var.oai_sku_name
  oai_custom_subdomain_name              = "${var.oai_custom_subdomain_name}${random_integer.number.result}"
  oai_dynamic_throttling_enabled         = var.oai_dynamic_throttling_enabled
  oai_fqdns                              = var.oai_fqdns
  oai_local_auth_enabled                 = var.oai_local_auth_enabled
  oai_outbound_network_access_restricted = var.oai_outbound_network_access_restricted
  oai_public_network_access_enabled      = var.oai_public_network_access_enabled
  oai_customer_managed_key               = var.oai_customer_managed_key
  oai_identity                           = var.oai_identity
  oai_network_acls                       = var.oai_network_acls
  oai_storage                            = var.oai_storage
  oai_model_deployment                   = var.oai_model_deployment

  # 05 cosmosdb
  #============#
  cosmosdb_name                              = "${var.cosmosdb_name}${random_integer.number.result}"
  cosmosdb_offer_type                        = var.cosmosdb_offer_type
  cosmosdb_kind                              = var.cosmosdb_kind
  cosmosdb_automatic_failover                = var.cosmosdb_automatic_failover
  use_cosmosdb_free_tier                     = var.use_cosmosdb_free_tier
  cosmosdb_consistency_level                 = var.cosmosdb_consistency_level
  cosmosdb_max_interval_in_seconds           = var.cosmosdb_max_interval_in_seconds
  cosmosdb_max_staleness_prefix              = var.cosmosdb_max_staleness_prefix
  cosmosdb_geo_locations                     = var.cosmosdb_geo_locations
  cosmosdb_capabilities                      = var.cosmosdb_capabilities
  cosmosdb_virtual_network_subnets           = var.cosmosdb_virtual_network_subnets
  cosmosdb_is_virtual_network_filter_enabled = var.cosmosdb_is_virtual_network_filter_enabled
  cosmosdb_public_network_access_enabled     = var.cosmosdb_public_network_access_enabled

  # 06 app services (librechat app + meilisearch)
  #=============================================#
  # App Service Plan
  app_service_name     = "${var.app_service_name}${random_integer.number.result}"
  app_service_sku_name = var.app_service_sku_name

  # LibreChat App
  libre_app_name                          = "${var.libre_app_name}${random_integer.number.result}"
  libre_app_virtual_network_subnet_id     = var.libre_app_virtual_network_subnet_id
  libre_app_public_network_access_enabled = var.libre_app_public_network_access_enabled
  libre_app_allowed_subnets               = var.libre_app_allowed_subnets
  libre_app_allowed_ip_addresses          = var.libre_app_allowed_ip_addresses

  ### LibreChat App Settings ###
  # Server Config
  libre_app_title         = var.libre_app_title
  libre_app_custom_footer = var.libre_app_custom_footer
  libre_app_host          = var.libre_app_host
  libre_app_port          = var.libre_app_port
  libre_app_docker_image  = var.libre_app_docker_image
  libre_app_mongo_uri     = var.libre_app_mongo_uri
  libre_app_domain_client = var.libre_app_domain_client
  libre_app_domain_server = var.libre_app_domain_server

  # Debug Config
  libre_app_debug_logging = var.libre_app_debug_logging
  libre_app_debug_console = var.libre_app_debug_console

  # Endpoints
  libre_app_endpoints = var.libre_app_endpoints

  # Azure OpenAI Config
  libre_app_az_oai_api_key                      = var.libre_app_az_oai_api_key
  libre_app_az_oai_models                       = var.libre_app_az_oai_models
  libre_app_az_oai_use_model_as_deployment_name = var.libre_app_az_oai_use_model_as_deployment_name
  libre_app_az_oai_instance_name                = var.libre_app_az_oai_instance_name
  libre_app_az_oai_api_version                  = var.libre_app_az_oai_api_version
  libre_app_az_oai_dall3_api_version            = var.libre_app_az_oai_dall3_api_version
  libre_app_az_oai_dall3_deployment_name        = var.libre_app_az_oai_dall3_deployment_name

  # Plugins
  libre_app_debug_plugins     = var.libre_app_debug_plugins
  libre_app_plugins_creds_key = var.libre_app_plugins_creds_key
  libre_app_plugins_creds_iv  = var.libre_app_plugins_creds_iv

  # Search
  libre_app_enable_meilisearch = var.libre_app_enable_meilisearch

  # User Registration
  libre_app_allow_email_login         = var.libre_app_allow_email_login
  libre_app_allow_registration        = var.libre_app_allow_registration
  libre_app_allow_unverified_email_login = var.libre_app_allow_unverified_email_login
  libre_app_allow_social_login        = var.libre_app_allow_social_login
  libre_app_allow_social_registration = var.libre_app_allow_social_registration
  libre_app_jwt_secret                = var.libre_app_jwt_secret
  libre_app_jwt_refresh_secret        = var.libre_app_jwt_refresh_secret

  # Violations
  libre_app_violations = var.libre_app_violations

  # Custom Domain and Managed Certificate (Optional)
  libre_app_custom_domain_create     = var.libre_app_custom_domain_create
  librechat_app_custom_domain_name   = var.librechat_app_custom_domain_name
  librechat_app_custom_dns_zone_name = var.librechat_app_custom_dns_zone_name
  dns_resource_group_name            = var.dns_resource_group_name

    # RAG API Container App
  rag_api_app_name = "${var.rag_api_app_name}${random_integer.number.result}"
  rag_api_app_image = var.rag_api_app_image
  rag_api_app_cpu = var.rag_api_app_cpu
  rag_api_app_memory = var.rag_api_app_memory
  rag_api_subnet_config = var.rag_api_subnet_config
  ## rag_api_dns_zone_name = var.rag_api_dns_zone_name

  # PostgreSQL Flexible Server
  pgsql_server_name            = "${var.pgsql_server_name}${random_integer.number.result}"
  pgsql_version                = var.pgsql_version
  pgsql_administrator_login    = var.pgsql_administrator_login
  #pgsql_administrator_password = var.pgsql_administrator_password  
  pgsql_sku_name               = var.pgsql_sku_name
  pgsql_storage_mb             = var.pgsql_storage_mb
  pgsql_backup_retention_days  = var.pgsql_backup_retention_days
  database_extensions          = var.database_extensions  

}