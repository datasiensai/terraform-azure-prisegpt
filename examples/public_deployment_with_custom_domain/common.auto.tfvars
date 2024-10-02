### 01 Common Variables + RG ###
resource_group_name = "PriseGPT-RG"
location            = "SwedenCentral" ## Change this to your desired location - For EU customers SwedenCentral is recommended

tags = {
  Terraform   = "True"
  Description = "PriseGPT - ChatGPT for the Enterprise"
  Author      = "Biju Krishnan"
  GitHub      = "https://github.com/datasiensai/prisegpt/"
}

### 02 networking ###
virtual_network_name = "prisegpt-vnet" ## Change this to your vnet name
vnet_address_space   = ["10.0.0.0/8"] ## Change this to your vnet address space
subnet_config = {
  subnet_name                                   = "prisegpt-sub" ## Change this to your subnet name
  subnet_address_space                          = ["10.3.0.0/16"] ## Change this to your subnet address space
  service_endpoints                             = ["Microsoft.AzureCosmosDB", "Microsoft.Web", "Microsoft.KeyVault"]
  private_endpoint_network_policies_enabled     = "Enabled"
  private_link_service_network_policies_enabled = false
  subnets_delegation_settings = {
    app-service-plan = [
      {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    ]
  }
}

### 03 KeyVault ###
kv_name                  = "prisegptkv" ## Change this to your keyvault name
kv_sku                   = "standard"
kv_fw_default_action     = "Deny"
kv_fw_bypass             = "AzureServices"
kv_fw_allowed_ips        = ["0.0.0.0/0"] # Allow all IPs if you dont have a fixed ip
kv_fw_network_subnet_ids = null          # leave null to allow access from default subnet of this module

### 04 Create OpenAI Service ###
oai_account_name                       = "prisegptoai" ## Change this to your openai account name
oai_sku_name                           = "S0"
oai_custom_subdomain_name              = "prisegptoai" ## Change this to your openai custom subdomain name
oai_dynamic_throttling_enabled         = false
oai_fqdns                              = []
oai_local_auth_enabled                 = true
oai_outbound_network_access_restricted = false
oai_public_network_access_enabled      = true
oai_customer_managed_key               = null
oai_identity = {
  type = "SystemAssigned"
}
oai_network_acls = null
oai_storage      = null
## Change section below to your desired models
oai_model_deployment = [
  {
    deployment_id   = "gpt-4o"
    model_name      = "gpt-4o"
    model_format    = "OpenAI"
    model_version   = "2024-08-06"
    sku_name        = "Standard"
    sku_capacity    = 8
    scale_type      = "standard"
  },
  {
    deployment_id   = "gpt-4o-mini"
    model_name      = "gpt-4o-mini"
    model_format    = "OpenAI"
    model_version   = "2024-07-18"
    sku_name        = "Standard"
    sku_capacity    = 8
    scale_type      = "standard"
  },
  {
    deployment_id   = "gpt-4"
    model_name      = "gpt-4"
    model_format    = "OpenAI"
    model_version   = "turbo-2024-04-09"
    sku_name        = "Standard"
    sku_capacity    = 8
    scale_type      = "standard"
  },
  {
    deployment_id   = "text-embedding-3-large"
    model_name      = "text-embedding-3-large"
    model_format    = "OpenAI"
    model_version   = "1"
    sku_name        = "Standard"
    sku_capacity    = 8
    scale_type      = "standard"
  },
  {
    deployment_id   = "dall-e-3"
    model_name      = "dall-e-3"
    model_format    = "OpenAI"
    model_version   = "3.0"
    sku_name        = "Standard"
    sku_capacity    = 1
    scale_type      = "standard"
  }
]

### 05 cosmosdb ###
cosmosdb_name                    = "prisegptcosmosdb" ## Change this to your cosmosdb name
cosmosdb_offer_type              = "Standard"
cosmosdb_kind                    = "MongoDB"
cosmosdb_automatic_failover      = false
use_cosmosdb_free_tier           = true
cosmosdb_consistency_level       = "BoundedStaleness"
cosmosdb_max_interval_in_seconds = 10
cosmosdb_max_staleness_prefix    = 200
cosmosdb_geo_locations = [
  {
    location          = "SwedenCentral"
    failover_priority = 0
  }
]
cosmosdb_capabilities                      = ["EnableMongo", "MongoDBv3.4"]
cosmosdb_virtual_network_subnets           = null # leave null to allow access from default subnet of this module
cosmosdb_is_virtual_network_filter_enabled = true
cosmosdb_public_network_access_enabled     = true

### 06 app services (librechat app + meilisearch) ###
# App Service Plan
app_service_name     = "prisegptasp"
app_service_sku_name = "B1"

# LibreChat App Service
libre_app_name                          = "prisegptchatapp"
libre_app_public_network_access_enabled = true
libre_app_virtual_network_subnet_id     = null # Access is allowed on the built in subnet of this module. If networking is created as part of the module, this will be automatically populated if value is 'null' (priority 100)
libre_app_allowed_subnets               = null # Add any other subnet ids to allow access to the app service (optional)
libre_app_allowed_ip_addresses = [
  {
    ip_address = "0.0.0.0/0" # Allow all IPs for testing purposes
    priority   = 200
    name       = "ip-access-rule1"
    action     = "Allow"
  }
]

### LibreChat App Settings ###
# Server Config
libre_app_title         = "PRIVATE jl CHATBOT"
libre_app_custom_footer = "Privately hosted GPT App powered by Azure OpenAI and LibreChat"
libre_app_host          = "0.0.0.0"
libre_app_port          = 80
libre_app_docker_image  = "ghcr.io/danny-avila/librechat-dev-api:latest" 
libre_app_mongo_uri     = null               # leave null to use the cosmosdb uri saved in keyvault created by this module
libre_app_domain_client = "http://localhost:80"
libre_app_domain_server = "http://localhost:80"

# debug logging
libre_app_debug_logging = true
libre_app_debug_console = false

# Endpoints
libre_app_endpoints = "azureOpenAI,gptPlugins,azureAssistants"
libre_app_plugin_models = "gpt-4o"
# Azure OpenAI
libre_app_az_oai_api_key                      = null # leave null to use the key saved in keyvault created by this module
libre_app_az_oai_models                       = "gpt-4o,gpt-4o-mini,gpt-4"
libre_app_az_oai_use_model_as_deployment_name = true
libre_app_az_oai_instance_name                = null # leave null to use the instance name created by this module
libre_app_az_oai_api_version                  = "2023-07-01-preview"
libre_app_az_oai_dall3_api_version            = "2023-12-01-preview"
libre_app_az_oai_dall3_deployment_name        = "dall-e-3"
libre_app_az_oai_title_convo_model            = "gpt-4o-mini"

# Plugins
libre_app_debug_plugins     = true
libre_app_plugins_creds_key = null # leave null to use the key saved in keyvault created by this module
libre_app_plugins_creds_iv  = null # leave null to use the iv saved in keyvault created by this module

# Search
libre_app_enable_meilisearch = false

# User Registration
libre_app_allow_email_login         = true
libre_app_allow_registration        = true
libre_app_allow_unverified_email_login = true
libre_app_allow_social_login        = false
libre_app_allow_social_registration = false
libre_app_jwt_secret                = null # leave null to use the secret saved in keyvault created by this module
libre_app_jwt_refresh_secret        = null # leave null to use the refresh secret saved in keyvault created by this module

# violations
libre_app_violations = {
  enabled                      = false
  ban_duration                 = 1000 * 60 * 60 * 2
  ban_interval                 = 20
  login_violation_score        = 1
  registration_violation_score = 1
  concurrent_violation_score   = 1
  message_violation_score      = 1
  non_browser_violation_score  = 20
  login_max                    = 7
  login_window                 = 5
  register_max                 = 5
  register_window              = 60
  limit_concurrent_messages    = false
  concurrent_message_max       = 2
  limit_message_ip             = false
  message_ip_max               = 40
  message_ip_window            = 1
  limit_message_user           = false
  message_user_max             = 40
  message_user_window          = 1
}

# Custom Domain and Managed Certificate (Optional)
libre_app_custom_domain_create     = false
librechat_app_custom_domain_name   = "privategptchatbot"
librechat_app_custom_dns_zone_name = "domain.com"
dns_resource_group_name            = "DNS-Resource-Group-Name"


### 07 RAG API Container App - Change values below to your desired values ###
rag_api_app_name = "prisegptragapi"
rag_api_app_image = "ghcr.io/danny-avila/librechat-rag-api-dev:latest"
rag_api_app_cpu = "1.0"
rag_api_app_memory = "2.0Gi"
rag_api_subnet_config = {
  subnet_name          = "rag-api-subnet"
  subnet_address_space = ["10.5.0.0/16"]
}
rag_api_app_embeddings_model = "text-embedding-3-large" # text-embedding-3-large is $0.00013/1000 tokens. This can be any embedding model supported by Azure OpenAI text-embedding-ada-002 $0.0001/1000 tokens or text-embedding-3-small $0.00002/1000 tokens
rag_api_app_embeddings_provider = "azure"
rag_api_app_api_version = "2023-05-15"



## pgsql
pgsql_server_name = "prisegptpgsql" ## Change this to your pgsql server name
pgsql_version = "13"
pgsql_administrator_login = "admin"
pgsql_storage_mb = 32768 # 32GB of storage is the minimum for Azure Postgres Flexible Server
pgsql_sku_name = "B_Standard_B1ms" 
## Change this to your desired sku - B1ms (1vcore/2GB) is $14/month - 
## The B-series is burstable CPU and cheaper. If you wish for a dedicate vcore, you can change this to GP_Standard_D2ds_v5 which is $136 with 2vcore/8GB
pgsql_backup_retention_days = 7
database_extensions = ["vector"]
