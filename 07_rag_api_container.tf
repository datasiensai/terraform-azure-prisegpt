resource "azurerm_container_app_environment" "rag_api_app" {
  name                              = "cae-${rag_api_app_name}"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.az_openai_rg.name
  internal_load_balancer_enabled    = true
  tags =  var.tags
}

resource "azurerm_container_app" "rag_api_app_name" {
  name                         = "ca-${rag_api_app_name}"
  container_app_environment_id = azurerm_container_app_environment.rag_api_app.id
  resource_group_name          = azurerm_resource_group.az_openai_rg.name
  revision_mode                = "Single"
  

 
  registry {
    server               = "ghcr.io"    
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage = 100
    }

  }

  template {
    container {
      name   = "${rag_api_app_name}"
      image  = "danny-avila/librechat-rag-api-dev:latest"
      cpu    = "1.0"
      memory = "2.0Gi"
    }
  }  


}