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

      # Environment variables for the container
      # Many of these reference secrets defined below
      env {
        name        = "RAG_AZURE_OPENAI_API_KEY"
        secret_name = "openai-api-key"
      }
      # ... (other env variables omitted for brevity)
    }
  }

  # Define secrets for the Container App
  secret {
    name  = "openai-api-key"
    value = azurerm_cognitive_account.az_openai.primary_access_key
  }
  # ... (other secrets omitted for brevity)

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