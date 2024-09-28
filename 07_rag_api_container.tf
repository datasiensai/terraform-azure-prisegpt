resource "azurerm_container_app_environment" "rag_api_app" {
  name                              = "cae-${var.rag_api_app_name}"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.az_openai_rg.name
  internal_load_balancer_enabled    = true
  infrastructure_subnet_id          = azurerm_subnet.rag_api_subnet.id
  log_analytics_workspace_id        = azurerm_log_analytics_workspace.rag_api_logs.id
  tags                              = var.tags
}

resource "azurerm_container_app" "rag_api_app_name" {
  name                         = "ca-${var.rag_api_app_name}"
  container_app_environment_id = azurerm_container_app_environment.rag_api_app.id
  resource_group_name          = azurerm_resource_group.az_openai_rg.name
  revision_mode                = "Single"
  # Enable System Assigned Managed Identity
  identity {
    type = "SystemAssigned"  # This enables a system-assigned identity
  }

  template {
    min_replicas = 1
    max_replicas = 2
    container {
      name   = var.rag_api_app_name
      image  = "ghcr.io/danny-avila/librechat-rag-api-dev:latest"
      cpu    = "1.0"
      memory = "2.0Gi"

      env {
        name  = "RAG_AZURE_OPENAI_API_KEY"
        value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_primary_key.id})"
      }
      env {
        name  = "RAG_AZURE_OPENAI_ENDPOINT"
        value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_endpoint.id})"
      }
      env {
        name  = "EMBEDDINGS_PROVIDER"
        value = var.rag_api_app_embeddings_provider
      }
      env {
        name  = "EMBEDDINGS_MODEL"
        value = var.rag_api_app_embeddings_model
      }
      env {
        name  = "OPENAI_API_VERSION"
        value = var.rag_api_app_api_version
      }
      env {
        name  = "VECTOR_DB_TYPE"
        value = "pgvector"
      }
      env {
        name  = "POSTGRES_DB"
        value = "postgres"  # Default database name for PostgreSQL
      }
      env {
        name  = "POSTGRES_USER"
        value = azurerm_postgresql_flexible_server.default.administrator_login
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = azurerm_postgresql_flexible_server.default.administrator_password
      }
      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.default.fqdn
      }
      env {
        name  = "DB_PORT"
        value = "5432"  # Default PostgreSQL port
      }
      env {
        name  = "DEBUG_RAG_API"
        value = "true"  # Set Debug to true
      }
    }
  }

  secret {
    name  = "openai-api-key"
    value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_primary_key.id})"
  }

  secret {
    name  = "openai-endpoint"
    value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_endpoint.id})"
  }

  secret {
    name  = "postgres-user"
    value = azurerm_postgresql_flexible_server.default.administrator_login
  }

  secret {
    name  = "postgres-password"
    value = azurerm_postgresql_flexible_server.default.administrator_password
  }

  secret {
    name  = "postgres-host"
    value = azurerm_postgresql_flexible_server.default.fqdn
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

}

resource "azurerm_log_analytics_workspace" "rag_api_logs" {
  name                = "log-${var.rag_api_app_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_openai_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

output "rag_api_static_ip" {
  value = azurerm_container_app_environment.rag_api_app.static_ip_address
}

output "rag_api_default_domain" {
  value = azurerm_container_app_environment.rag_api_app.default_domain
}

output "rag_api_application_url" {
  value = "https://${azurerm_container_app.rag_api_app_name.latest_revision_fqdn}"
}