resource "azurerm_container_app_environment" "rag_api_app" {
  name                              = "cae-${var.rag_api_app_name}"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.az_openai_rg.name
  internal_load_balancer_enabled    = true
  infrastructure_subnet_id          = azurerm_subnet.rag_api_subnet.id
  tags                              = var.tags
}

resource "azurerm_container_app" "rag_api_app_name" {
  name                         = "ca-${var.rag_api_app_name}"
  container_app_environment_id = azurerm_container_app_environment.rag_api_app.id
  resource_group_name          = azurerm_resource_group.az_openai_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = var.rag_api_app_name
      image  = "ghcr.io/danny-avila/librechat-rag-api-dev:latest"
      cpu    = "1.0"
      memory = "2.0Gi"

      env {
        name  = "RAG_AZURE_OPENAI_API_KEY"
        value = var.libre_app_az_oai_api_key != null ? var.libre_app_az_oai_api_key : "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.openai_primary_key.id})"
      }
      env {
        name  = "RAG_AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.az_openai.endpoint
      }
      env {
        name  = "EMBEDDINGS_PROVIDER"
        value = "azure"
      }
      env {
        name  = "EMBEDDINGS_MODEL"
        value = "text-embedding-3-large"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
