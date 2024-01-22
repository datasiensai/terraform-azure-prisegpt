### 01 common + RG ###
variable "location" {
  type        = string
  default     = "uksouth"
  description = "Azure region where resources will be hosted."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pairs that is used to tag resources created."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create where the cognitive account OpenAI service is hosted."
  nullable    = false
}

### 02 networking ###
variable "virtual_network_name" {
  type        = string
  default     = "openai-vnet-9000"
  description = "Name of the virtual network where resources are attached."
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.4.0.0/24"]
  description = "value of the address space for the virtual network."
}

variable "subnet_config" {
  type = object({
    subnet_name                                   = string
    subnet_address_space                          = list(string)
    service_endpoints                             = list(string)
    private_endpoint_network_policies_enabled     = bool
    private_link_service_network_policies_enabled = bool
    subnets_delegation_settings = map(list(object({
      name    = string
      actions = list(string)
    })))
  })
  default = {
    subnet_name                                   = "app-cosmos-sub"
    subnet_address_space                          = ["10.4.0.0/24"]
    service_endpoints                             = ["Microsoft.AzureCosmosDB", "Microsoft.Web"]
    private_endpoint_network_policies_enabled     = false
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
  description = "A list of subnet configuration objects to create subnets in the virtual network."
}

### 03 key vault ###
variable "kv_name" {
  type        = string
  description = "Name of the Key Vault to create (solution secrets)."
  default     = "openaikv9000"
}

variable "kv_sku" {
  type        = string
  description = "SKU of the Key Vault to create."
  default     = "standard"
}

variable "kv_fw_default_action" {
  type        = string
  default     = "Deny"
  description = "Default action for key vault firewall rules."

}

variable "kv_fw_bypass" {
  type        = string
  default     = "AzureServices"
  description = "List of key vault firewall rules to bypass."
}

variable "kv_fw_allowed_ips" {
  type        = list(string)
  default     = []
  description = "value of key vault firewall allowed ip rules."
}

variable "kv_fw_network_subnet_ids" {
  description = "The virtual network subnets to associate with the Cosmos DB account (Service Endpoint). If networking is created as part of the module, this will be automatically populated."
  type        = list(string)
  default     = null
}

### 04 openai service ###
variable "oai_account_name" {
  type        = string
  default     = "az-openai-account"
  description = "The name of the OpenAI service."
}

variable "oai_sku_name" {
  type        = string
  description = "SKU name of the OpenAI service."
  default     = "S0"
}

variable "oai_custom_subdomain_name" {
  type        = string
  description = "The subdomain name used for token-based authentication. Changing this forces a new resource to be created. (normally the same as the account name)"
  default     = "demo-account"
}

variable "oai_dynamic_throttling_enabled" {
  type        = bool
  default     = true
  description = "Whether or not dynamic throttling is enabled. Defaults to `true`."
}

variable "oai_fqdns" {
  type        = list(string)
  default     = []
  description = "A list of FQDNs to be used for token-based authentication. Changing this forces a new resource to be created."
}

variable "oai_local_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`."
}

variable "oai_outbound_network_access_restricted" {
  type        = bool
  default     = false
  description = "Whether or not outbound network access is restricted. Defaults to `false`."
}

variable "oai_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether or not public network access is enabled. Defaults to `false`."
}

variable "oai_customer_managed_key" {
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
    type = object({
      key_vault_key_id   = (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this OpenAI Account.
      identity_client_id = (Optional) The Client ID of the User Assigned Identity that has access to the key. This property only needs to be specified when there're multiple identities attached to the OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
  description = <<-DESCRIPTION
    type = object({
      type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
      identity_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_network_acls" {
  type = set(object({
    default_action = string
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  }))
  default     = null
  description = <<-DESCRIPTION
    type = set(object({
      default_action = (Required) The Default Action to use when no rules match from ip_rules / virtual_network_rules. Possible values are `Allow` and `Deny`.
      ip_rules       = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Cognitive Account.
      virtual_network_rules = optional(set(object({
        subnet_id                            = (Required) The ID of a Subnet which should be able to access the OpenAI Account.
        ignore_missing_vnet_service_endpoint = (Optional) Whether ignore missing vnet service endpoint or not. Default to `false`.
      })))
    }))
  DESCRIPTION
}

variable "oai_storage" {
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
    type = list(object({
      storage_account_id = (Required) Full resource id of a Microsoft.Storage resource.
      identity_client_id = (Optional) The client ID of the managed identity associated with the storage resource.
    }))
  DESCRIPTION
  nullable    = false
}

variable "oai_model_deployment" {
  type = list(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    scale_type      = string
    scale_tier      = optional(string)
    scale_size      = optional(number)
    scale_family    = optional(string)
    scale_capacity  = optional(number)
    rai_policy_name = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
      type = list(object({
        deployment_id   = (Required) The name of the Cognitive Services Account `Model Deployment`. Changing this forces a new resource to be created.
        model_name = {
          model_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.
          model_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Cognitive Services Account Deployment model.
        }
        scale = {
          scale_type     = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.
          scale_tier     = (Optional) Possible values are Free, Basic, Standard, Premium, Enterprise. Changing this forces a new resource to be created.
          scale_size     = (Optional) The SKU size. When the name field is the combination of tier and some other value, this would be the standalone code. Changing this forces a new resource to be created.
          scale_family   = (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here. Changing this forces a new resource to be created.
          scale_capacity = (Optional) Tokens-per-Minute (TPM). If the SKU supports scale out/in then the capacity integer should be included. If scale out/in is not possible for the resource this may be omitted. Default value is 1. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
      }))
  DESCRIPTION
  nullable    = false
}

### 05 OpenAI CosmosDB ###
variable "cosmosdb_name" {
  description = "The name of the Cosmos DB account"
  type        = string
  default     = "openaicosmosdb"
}

variable "cosmosdb_offer_type" {
  description = "The offer type to use for the Cosmos DB account"
  type        = string
  default     = "Standard"
}

variable "cosmosdb_kind" {
  description = "The kind of Cosmos DB to create"
  type        = string
  default     = "MongoDB"
}

variable "cosmosdb_automatic_failover" {
  description = "Whether to enable automatic failover for the Cosmos DB account"
  type        = bool
  default     = false
}

variable "use_cosmosdb_free_tier" {
  description = "Whether to enable the free tier for the Cosmos DB account. This needs to be false if another instance already uses free tier."
  type        = bool
  default     = true
}

variable "cosmosdb_consistency_level" {
  description = "The consistency level of the Cosmos DB account"
  type        = string
  default     = "BoundedStaleness"
}

variable "cosmosdb_max_interval_in_seconds" {
  description = "The maximum staleness interval in seconds for the Cosmos DB account"
  type        = number
  default     = 10
}

variable "cosmosdb_max_staleness_prefix" {
  description = "The maximum staleness prefix for the Cosmos DB account"
  type        = number
  default     = 200
}

variable "cosmosdb_geo_locations" {
  description = "The geo-locations for the Cosmos DB account"
  type = list(object({
    location          = string
    failover_priority = number
  }))
  default = [
    {
      location          = "uksouth"
      failover_priority = 0
    }
  ]
}

variable "cosmosdb_capabilities" {
  description = "The capabilities for the Cosmos DB account"
  type        = list(string)
  default     = ["EnableMongo", "MongoDBv3.4"]
}

variable "cosmosdb_virtual_network_subnets" {
  description = "The virtual network subnets to associate with the Cosmos DB account (Service Endpoint). If networking is created as part of the module, this will be automatically populated."
  type        = list(string)
  default     = null
}

variable "cosmosdb_is_virtual_network_filter_enabled" {
  description = "Whether to enable virtual network filtering for the Cosmos DB account"
  type        = bool
  default     = true
}

variable "cosmosdb_public_network_access_enabled" {
  description = "Whether to enable public network access for the Cosmos DB account"
  type        = bool
  default     = true
}

### 06 app services (librechat app + meilisearch) ###
# App service Plan
variable "app_service_name" {
  type        = string
  description = "Name of the Linux App Service Plan."
  default     = "openai-asp9000"
}

variable "app_service_sku_name" {
  type        = string
  description = "The SKU name of the App Service Plan."
  default     = "B1"
}

# # Meilisearch App Service
# variable "meilisearch_app_name" {
#   type        = string
#   description = "Name of the meilisearch App Service."
#   default     = "meilisearchapp9000"

# }

# variable "meilisearch_app_virtual_network_subnet_id" {
#   type        = string
#   description = "The ID of the subnet to deploy the meilisearch App Service in."
#   default     = null
# }

# variable "meilisearch_app_key" {
#   type        = string
#   description = "The Meilisearch API Key to use for authentication."
#   default     = null
#   sensitive   = true
# }

# LibreChat App Service
variable "libre_app_name" {
  type        = string
  description = "Name of the LibreChat App Service."
  default     = "librechatapp9000"
}

variable "libre_app_public_network_access_enabled" {
  type        = bool
  description = "Whether or not public network access is enabled. Defaults to `false`."
  default     = true
}

variable "libre_app_virtual_network_subnet_id" {
  type        = string
  description = "The ID of the subnet to deploy the LibreChat App Service in."
  default     = null
}

variable "libre_app_allowed_ip_address" {
  type        = string
  description = "The IP Address to allow access to the LibreChat App Service from. (Change to your IP Address). default is allow all"
  default     = "0.0.0.0/0"
}

# LibreChat App Service App Settings
# Server Config
variable "libre_app_title" {
  type        = string
  description = "Add a custom title for the App."
  default     = "PrivateGPT"
}

variable "libre_app_custom_footer" {
  type        = string
  description = "Add a custom footer for the App."
  default     = "Privately hosted chat app powered by Azure OpenAI and LibreChat."
}

variable "libre_app_host" {
  type        = string
  description = "he server will listen to localhost:3080 by default. You can change the target IP as you want. If you want to make this server available externally, for example to share the server with others or expose this from a Docker container, set host to 0.0.0.0 or your external IP interface."
  default     = "0.0.0.0"
}

variable "libre_app_port" {
  type        = number
  description = "The host port to listen on."
  default     = 3080
}

variable "libre_app_docker_image" {
  type        = string
  description = "The Docker Image to use for the App Service."
  default     = "ghcr.io/danny-avila/librechat-dev-api:latest"
}

variable "libre_app_mongo_uri" {
  type        = string
  description = "The MongoDB Connection String to connect to."
  default     = null
  sensitive   = true
}

variable "libre_app_domain_client" {
  type        = string
  description = "To use locally, set DOMAIN_CLIENT and DOMAIN_SERVER to http://localhost:3080 (3080 being the port previously configured).When deploying to a custom domain, set DOMAIN_CLIENT and DOMAIN_SERVER to your deployed URL, e.g. https://mydomain.example.com"
  default     = "http://localhost:3080"
}

variable "libre_app_domain_server" {
  type        = string
  description = "To use locally, set DOMAIN_CLIENT and DOMAIN_SERVER to http://localhost:3080 (3080 being the port previously configured).When deploying to a custom domain, set DOMAIN_CLIENT and DOMAIN_SERVER to your deployed URL, e.g. https://mydomain.example.com"
  default     = "http://localhost:3080"
}

# Debug logging
variable "libre_app_debug_logging" {
  type        = bool
  description = "LibreChat has central logging built into its backend (api). Log files are saved in /api/logs. Error logs are saved by default. Debug logs are enabled by default but can be turned off if not desired."
  default     = false
}

variable "libre_app_debug_console" {
  type        = bool
  description = "Enable verbose server output in the console, though it's not recommended due to high verbosity."
  default     = false
}

# Endpoints
variable "libre_app_endpoints" {
  type        = string
  description = "endpoints and models selection. E.g. 'openAI,azureOpenAI,bingAI,chatGPTBrowser,google,gptPlugins,anthropic'"
  default     = "azureOpenAI"
}

# Azure OpenAI
variable "libre_app_az_oai_api_key" {
  type        = string
  description = "Azure OpenAI API Key"
  default     = null
  sensitive   = true
}

variable "libre_app_az_oai_models" {
  type        = string
  description = "Azure OpenAI Models. E.g. 'gpt-4-1106-preview,gpt-4,gpt-3.5-turbo,gpt-3.5-turbo-1106,gpt-4-vision-preview'"
  default     = "gpt-4-1106-preview"
}

variable "libre_app_az_oai_use_model_as_deployment_name" {
  type        = bool
  description = "Azure OpenAI Use Model as Deployment Name"
  default     = true
}

variable "libre_app_az_oai_instance_name" {
  type        = string
  description = "Azure OpenAI Instance Name"
  default     = null
}

variable "libre_app_az_oai_api_version" {
  type        = string
  description = "Azure OpenAI API Version"
  default     = "2023-07-01-preview"
}

variable "libre_app_az_oai_dall3_api_version" {
  type        = string
  description = "Azure OpenAI DALL-E API Version"
  default     = "2023-12-01-preview"
}

variable "libre_app_az_oai_dall3_deployment_name" {
  type        = string
  description = "Azure OpenAI DALL-E Deployment Name"
  default     = "dall-e-3"
}

# Plugins
variable "libre_app_debug_plugins" {
  type        = bool
  description = "Enable debug mode for Libre App plugins."
  default     = false
}

variable "libre_app_plugins_creds_key" {
  type        = string
  description = "Libre App Plugins Creds Key"
  default     = null
  sensitive   = true
}

variable "libre_app_plugins_creds_iv" {
  type        = string
  description = "Libre App Plugins Creds IV"
  default     = null
  sensitive   = true
}

# variable "libre_app_plugin_models" {
#   type        = string
#   description = "Libre App Plugin Models e.g. 'gpt-4,dall-e-3'"
#   default     = "gpt-4,dall-e-3"
# }

# variable "libre_app_plugins_use_azure" {
#   type        = bool
#   description = "Libre App Plugins Use Azure, required for Azure OpenAI Plugins e.g. 'dall-e-3'"
#   default     = true
# }

# Search
variable "libre_app_enable_meilisearch" {
  type        = bool
  description = "Enable Meilisearch"
  default     = false
}

# variable "libre_app_disable_meilisearch_analytics" {
#   type        = bool
#   description = "Disable Meilisearch Analytics"
#   default     = true
# }

# variable "libre_app_meili_host" {
#   type        = string
#   description = "For the API server to connect to the search server. E.g. https://meilisearch.example.com"
#   default     = null
# }

variable "libre_app_meili_key" {
  type        = string
  description = "Meilisearch API Key"
  default     = null
  sensitive   = true
}

# User Registration
variable "libre_app_allow_email_login" {
  type        = bool
  description = "Allow Email Login"
  default     = true
}

variable "libre_app_allow_registration" {
  type        = bool
  description = "Allow Registration"
  default     = true
}

variable "libre_app_allow_social_login" {
  type        = bool
  description = "Allow Social Login"
  default     = false
}

variable "libre_app_allow_social_registration" {
  type        = bool
  description = "Allow Social Registration"
  default     = false
}

variable "libre_app_jwt_secret" {
  type        = string
  description = "JWT Secret"
  default     = null
  sensitive   = true
}

variable "libre_app_jwt_refresh_secret" {
  type        = string
  description = "JWT Refresh Secret"
  default     = null
  sensitive   = true
}


# LibreChat App Service App Settings

# # DNS zone #
# variable "create_dns_zone" {
#   description = "Create a DNS zone for the CDN profile. If set to false, an existing DNS zone must be provided."
#   type        = bool
#   default     = false
# }

# variable "custom_domain_config" {
#   type = object({
#     zone_name = string
#     host_name = string
#     ttl       = optional(number, 3600)
#     tls = optional(list(object({
#       certificate_type    = optional(string, "ManagedCertificate")
#       minimum_tls_version = optional(string, "TLS12")
#     })))
#   })
#   default = {
#     zone_name = "mydomain7335.com"
#     host_name = "PrivateGPT"
#     ttl       = 3600
#     tls = [{
#       certificate_type    = "ManagedCertificate"
#       minimum_tls_version = "TLS12"
#     }]
#   }
#   description = <<-DESCRIPTION
#     type = object({
#       zone_name = (Required) The name of the DNS zone to create the CNAME and TXT record in for the CDN Front Door Custom domain.
#       host_name = (Required) The host name of the DNS record to create. (e.g. Contoso)
#       ttl       = (Optional) The TTL of the DNS record to create. (e.g. 3600)
#       tls       = optional(list(object({
#         certificate_type    = (Optional) Defines the source of the SSL certificate. Possible values include 'CustomerCertificate' and 'ManagedCertificate'. Defaults to 'ManagedCertificate'.
#         NOTE: It may take up to 15 minutes for the Front Door Service to validate the state and Domain ownership of the Custom Domain.
#         minimum_tls_version = (Optional) TLS protocol version that will be used for Https. Possible values include TLS10 and TLS12. Defaults to TLS12.
#       }))))
#     })
#   DESCRIPTION
# }

# # Front Door #
# variable "create_front_door_cdn" {
#   description = "Create a Front Door profile."
#   type        = bool
#   default     = false
# }

# variable "cdn_profile_name" {
#   description = "The name of the CDN profile to create."
#   type        = string
#   default     = "example-cdn-profile"
# }

# variable "cdn_sku_name" {
#   description = "Specifies the SKU for the CDN Front Door Profile. Possible values include 'Standard_AzureFrontDoor' and 'Premium_AzureFrontDoor'."
#   type        = string
#   default     = "Standard_AzureFrontDoor"
# }

# variable "cdn_endpoint" {
#   type = object({
#     name    = string
#     enabled = optional(bool, true)
#   })
#   default = {
#     name    = "PrivateGPT"
#     enabled = true
#   }
#   description = <<DESCRIPTION
#     typp = object({
#       name    = (Required) The name of the CDN endpoint to create.
#       enabled = (Optional) Is the CDN endpoint enabled? Defaults to `true`.
#     })
#   DESCRIPTION
# }

# variable "cdn_origin_groups" {
#   type = list(object({
#     name                                                      = string
#     session_affinity_enabled                                  = optional(bool, false)
#     restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 5)
#     health_probe = optional(object({
#       interval_in_seconds = optional(number, 100)
#       path                = optional(string, "/")
#       protocol            = optional(string, "Http")
#       request_type        = optional(string, "HEAD")
#     }))
#     load_balancing = optional(object({
#       additional_latency_in_milliseconds = optional(number, 50)
#       sample_size                        = optional(number, 4)
#       successful_samples_required        = optional(number, 3)
#     }))
#   }))
#   default = [
#     {
#       name                                                      = "PrivateGPTOriginGroup"
#       session_affinity_enabled                                  = false
#       restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 5
#       health_probe = {
#         interval_in_seconds = 100
#         path                = "/"
#         protocol            = "Http"
#         request_type        = "HEAD"
#       }
#       load_balancing = {
#         additional_latency_in_milliseconds = 50
#         sample_size                        = 4
#         successful_samples_required        = 3
#       }
#     }
#   ]
#   description = <<-DESCRIPTION
#     type = list(object({
#       name                                                      = (Required) The name of the CDN origin group to create.
#       session_affinity_enabled                                  = (Optional) Is session affinity enabled? Defaults to `false`.
#       restore_traffic_time_to_healed_or_new_endpoint_in_minutes = (Optional) The time in minutes to restore traffic to a healed or new endpoint. Defaults to `5`.
#       health_probe = (Optional) The health probe settings.
#       type = object({
#         interval_in_seconds = (Optional) The interval in seconds between health probes. Defaults to `100`.
#         path                = (Optional) The path to use for health probes. Defaults to `/`.
#         protocol            = (Optional) The protocol to use for health probes. Possible values include 'Http' and 'Https'. Defaults to `Http`.
#         request_type        = (Optional) The request type to use for health probes. Possible values include 'GET', 'HEAD', and 'OPTIONS'. Defaults to `HEAD`.
#       }))
#       load_balancing = (Optional) The load balancing settings.
#       type = object({
#         additional_latency_in_milliseconds = (Optional) The additional latency in milliseconds for probes to fall into the lowest latency bucket. Defaults to `50`.
#         sample_size                        = (Optional) The number of samples to take for load balancing decisions. Defaults to `4`.
#         successful_samples_required        = (Optional) The number of samples within the sample period that must succeed. Defaults to `3`.
#       }))
#     }))
#     DESCRIPTION
# }

# variable "cdn_gpt_origin" {
#   type = object({
#     name                           = string
#     origin_group_name              = string
#     enabled                        = optional(bool, true)
#     certificate_name_check_enabled = optional(bool, true)
#     http_port                      = optional(number, 80)
#     https_port                     = optional(number, 443)
#     priority                       = optional(number, 1)
#     weight                         = optional(number, 1000)
#   })
#   default = {
#     name                           = "PrivateGPTOrigin"
#     origin_group_name              = "PrivateGPTOriginGroup"
#     enabled                        = true
#     certificate_name_check_enabled = true
#     http_port                      = 80
#     https_port                     = 443
#     priority                       = 1
#     weight                         = 1000
#   }
#   description = <<-DESCRIPTION
#     type = object({
#       name                           = (Required) The name which should be used for this Front Door Origin. Changing this forces a new Front Door Origin to be created.
#       origin_group_name              = (Required) The name of the CDN origin group to associate this origin with.
#       enabled                        = (Optional) Is the CDN origin enabled? Defaults to `true`.
#       certificate_name_check_enabled = (Required) Specifies whether certificate name checks are enabled for this origin. Defaults to `true`.
#       http_port                      = (Optional) The HTTP port of the origin. (e.g. 80)
#       https_port                     = (Optional) The HTTPS port of the origin. (e.g. 443)
#       priority                       = (Optional) The priority of the origin. (e.g. 1)
#       weight                         = (Optional) The weight of the origin. (e.g. 1000)
#     })
#   DESCRIPTION
# }

# variable "cdn_route" {
#   type = object({
#     name                       = string
#     enabled                    = optional(bool, true)
#     forwarding_protocol        = optional(string, "HttpsOnly")
#     https_redirect_enabled     = optional(bool, false)
#     patterns_to_match          = optional(list(string), ["/*"])
#     supported_protocols        = optional(list(string), ["Http", "Https"])
#     cdn_frontdoor_origin_path  = optional(string, null)
#     cdn_frontdoor_rule_set_ids = optional(list(string), null)
#     link_to_default_domain     = optional(bool, false)
#     cache = optional(object({
#       query_string_caching_behavior = string
#       query_strings                 = optional(list(string), [])
#       compression_enabled           = bool
#       content_types_to_compress     = optional(list(string), [])
#     }))
#   })
#   default = {
#     name                       = "PrivateGPTRoute"
#     enabled                    = true
#     forwarding_protocol        = "HttpsOnly"
#     https_redirect_enabled     = false
#     patterns_to_match          = ["/*"]
#     supported_protocols        = ["Http", "Https"]
#     cdn_frontdoor_origin_path  = null
#     cdn_frontdoor_rule_set_ids = null
#     link_to_default_domain     = false
#     cache = {
#       query_string_caching_behavior = "IgnoreQueryString"
#       query_strings                 = []
#       compression_enabled           = false
#       content_types_to_compress     = []
#     }
#   }
#   description = <<-DESCRIPTION
#     type = object({
#       name                           = (Required) The name of the CDN route to create.
#       enabled                        = (Optional) Is the CDN route enabled? Defaults to `true`.
#       forwarding_protocol            = (Optional) The protocol this rule will use when forwarding traffic to backends. Possible values include `MatchRequest`, `HttpOnly` and `HttpsOnly`. Defaults to `HttpsOnly`.
#       https_redirect_enabled         = (Optional) Is HTTPS redirect enabled? Defaults to `false`.
#       patterns_to_match              = (Optional) The list of patterns to match for this rule. Defaults to `["/*"]`.
#       supported_protocols            = (Optional) The list of supported protocols for this rule. Defaults to `["Http", "Https"]`.
#       cdn_frontdoor_origin_path      = (Optional) The path to use when forwarding traffic to backends. Defaults to `null`.
#       cdn_frontdoor_rule_set_ids     = (Optional) The list of rule set IDs to associate with this rule. Defaults to `null`.
#       link_to_default_domain         = (Optional) Is the CDN route linked to the default domain? Defaults to `false`.
#       cache = (Optional) The CDN route cache settings.
#       type = object({
#         query_string_caching_behavior = (Required) The query string caching behavior. Possible values include 'IgnoreQueryString', 'BypassCaching', 'UseQueryString', and 'NotSet'. Defaults to 'IgnoreQueryString'.
#         query_strings                 = (Optional) The list of query strings to include or exclude from caching. Defaults to `[]`.
#         compression_enabled           = (Required) Is compression enabled? Defaults to `false`.
#         content_types_to_compress     = (Optional) The list of content types to compress. Defaults to `[]`.
#       })
#     })
#   DESCRIPTION
# }

# variable "cdn_firewall_policy" {
#   type = object({
#     create_waf                        = bool
#     name                              = string
#     enabled                           = optional(bool, true)
#     mode                              = optional(string, "Prevention")
#     redirect_url                      = optional(string)
#     custom_block_response_status_code = optional(number, 403)
#     custom_block_response_body        = optional(string)
#     custom_rules = optional(list(object({
#       name                           = string
#       action                         = string
#       enabled                        = optional(bool, true)
#       priority                       = number
#       type                           = string
#       rate_limit_duration_in_minutes = optional(number, 1)
#       rate_limit_threshold           = optional(number, 10)
#       match_conditions = list(object({
#         match_variable     = string
#         match_values       = list(string)
#         operator           = string
#         selector           = optional(string)
#         negation_condition = optional(bool)
#         transforms         = optional(list(string))
#       }))
#     })))
#   })
#   default = {
#     create_waf                        = true
#     name                              = "PrivateGPTFirewallPolicy"
#     enabled                           = true
#     mode                              = "Prevention"
#     redirect_url                      = null
#     custom_block_response_status_code = 403
#     custom_block_response_body        = "WW91ciByZXF1ZXN0IGhhcyBiZWVuIGJsb2NrZWQu"
#     custom_rules = [
#       {
#         name                           = "PrivateGPTFirewallPolicyCustomRule"
#         action                         = "Block"
#         enabled                        = true
#         priority                       = 100
#         type                           = "MatchRule"
#         rate_limit_duration_in_minutes = 1
#         rate_limit_threshold           = 10
#         match_conditions = [
#           {
#             match_variable     = "RemoteAddr"
#             match_values       = ["10.0.1.0/24", "10.0.2.0/24"]
#             operator           = "IPMatch"
#             selector           = null
#             negation_condition = null
#             transforms         = []
#           }
#         ]
#       }
#     ]
#   }
#   description = "The CDN firewall policies to create."
# }

# variable "cdn_security_policy" {
#   type = object({
#     name              = string
#     patterns_to_match = list(string)
#   })
#   default = {
#     name              = "PrivateGPTSecurityPolicy"
#     patterns_to_match = ["/*"]
#   }
#   description = <<-DESCRIPTION
#     type = object({
#       name                 = (Required) The name of the CDN security policy to create.
#       patterns_to_match    = (Required) The list of patterns to match for this policy. Defaults to `["/*"]`.
#     })
#   DESCRIPTION
# }