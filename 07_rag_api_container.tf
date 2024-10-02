# Create a Container App Environment for the RAG API
resource "azurerm_container_app_environment" "rag_api_app" {
  name                           = "cae-${var.rag_api_app_name}"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.az_openai_rg.name
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = azurerm_subnet.rag_api_subnet.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.rag_api_logs.id
  tags                           = var.tags
}

# Define the Container App for the RAG API
resource "azurerm_container_app" "rag_api_app_name" {
  name                         = "ca-${var.rag_api_app_name}"
  container_app_environment_id = azurerm_container_app_environment.rag_api_app.id
  resource_group_name          = azurerm_resource_group.az_openai_rg.name
  revision_mode                = "Single"
  
  # Enable System Assigned Managed Identity
  identity {
    type = "SystemAssigned"
  }

  # Define the container template
  template {
    min_replicas = 1
    max_replicas = 2
    container {
      name   = var.rag_api_app_name
      image  = "ghcr.io/danny-avila/librechat-rag-api-dev:latest"
      cpu    = "1.0"
      memory = "2.0Gi"

      env {
        name        = "RAG_AZURE_OPENAI_API_KEY"
        secret_name = "openai-api-key"
      }
      env {
        name        = "RAG_AZURE_OPENAI_ENDPOINT"
        secret_name = "openai-endpoint"
      }
      env {
        name        = "EMBEDDINGS_PROVIDER"
        value = var.rag_api_app_embeddings_provider
      }
      env {
        name        = "EMBEDDINGS_MODEL"
        value = var.rag_api_app_embeddings_model
      }
      env {
        name        = "OPENAI_API_VERSION"
        value = var.rag_api_app_api_version
      }
      env {
        name        = "VECTOR_DB_TYPE"
        value = "pgvector"
      }
      env {
        name        = "POSTGRES_DB"
        value = "postgres"  # Default database name for PostgreSQL
      }
      env {
        name        = "POSTGRES_USER"
        secret_name = "postgres-user"
      }
      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }
      env {
        name        = "DB_HOST"
        secret_name = "postgres-host"
      }
      env {
        name        = "DB_PORT"
        value = "5432"  # Default PostgreSQL port
      }
      env {
        name        = "DEBUG_RAG_API"
        value = "true"  # Set Debug to true
      }
    }
  }

  secret {
    name  = "openai-api-key"
    value = azurerm_cognitive_account.az_openai.primary_access_key
  }

  secret {
    name  = "openai-endpoint"
    value = azurerm_cognitive_account.az_openai.endpoint
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

  # Configure ingress for the Container App
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

# Create a Log Analytics workspace for the RAG API logs
resource "azurerm_log_analytics_workspace" "rag_api_logs" {
  name                = "log-${var.rag_api_app_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_openai_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Output the static IP of the Container App Environment
output "rag_api_static_ip" {
  value = azurerm_container_app_environment.rag_api_app.static_ip_address
}

# Output the default domain of the Container App Environment
output "rag_api_default_domain" {
  value = azurerm_container_app_environment.rag_api_app.default_domain
}

# Output the application URL of the Container App
output "rag_api_application_url" {
  value = "https://${azurerm_container_app.rag_api_app_name.ingress[0].fqdn}"
}