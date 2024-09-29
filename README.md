# Module: PriseGPT - ChatGPT for the Enterprise

## Current Version 1.x

Version **1.x.** LibreChat on Azure with following features
- Chat History (with CosmosDB)
- Chat with Files (with Azure Database for PostgreSQL Flexible Server)
- Artifacts similar to Claude to render code directly in chat window

## Coming next - Feature development

### v1.1.0 (in development)

- [ ] Support for Models available on demand via Azure AI Studio


### v1.0.0 (current)

- [x] LibreChat on Azure with following features
- [x] Chat History (with CosmosDB)
- [x] Chat with Files (with Azure Database for PostgreSQL Flexible Server)
- [x] Artifacts similar to Claude to render code directly in chat window


## Introduction

PriseGPT is a terraform module designed to provide enterprises with a ChatGPT-like solution within their Azure Virtual Private Cloud (VPC). It offers several key advantages:

- **Easy Maintenance**: Utilizing only containers and managed services, PriseGPT eliminates the need for virtual machines, simplifying maintenance and reducing operational overhead.

- **Private Network**: Experience ChatGPT-like features securely within your Azure virtual private network, ensuring that sensitive conversations remain within your organization's infrastructure.

- **Data Privacy**: Leverage Microsoft's data guarantees and prevent your corporate data from being used for training. Unlike OpenAI's public ChatGPT, where prompts may contribute to model training, PriseGPT ensures your data remains confidential.

- **Pay as You Grow**: Take advantage of your existing Azure credits and discounts to manage costs effectively. Scale your enterprise ChatGPT requirements in line with your usage and budget.

- **Unlimited Scalability**: Both the application and database components can be scaled infinitely as your user base grows, ensuring performance and availability at any scale.

- **White Labelled**: Customize the interface with your logos, colors, and corporate banners to maintain brand consistency and provide a seamless experience for your users.

By hosting OpenAI's models on Azure through PriseGPT, you gain enhanced security measures, from securing specific endpoints to implementing intricate role-based access controls. This solution offers a cost-effective approach to enterprise-grade AI capabilities, with conversation costs often under 10 cents.

For a deeper understanding of Azure OpenAI's capabilities, refer to this [Microsoft Learn article](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview/?wt.mc_id=DT-MVP-5004771). You can also review Azure [OpenAI's pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/) details for more information on costs.

## Architecture Diagram

![PriseGPT Azure Architecture](https://raw.githubusercontent.com/datasiensai/terraform-azure-prisegpt/main/assets/PriseGPT_Azure_Architecture.jpg)

## Examples

- [Public Deployment with Custom Domain and IP Whitelisting](https://github.com/datasiensai/terraform-azure-prisegpt/tree/main/examples/public_deployment_with_custom_domain)

## Screens

<table>
  <tr>
    <td><strong>Artifacts Like Claude</strong></td>
    <td><strong>Chat with Files</strong></td>
  </tr>
  <tr>
    <td><img src="https://github.com/datasiensai/terraform-azure-prisegpt/blob/main/assets/Artifacts.png" alt="Artifacts Like Claude" style="max-width: 100%; height: auto;"></td>
    <td><img src="https://github.com/datasiensai/terraform-azure-prisegpt/blob/main/assets/FileChat.png" alt="Chat with Files" style="max-width: 100%; height: auto;"></td>
  </tr>
  <tr>
    <td><strong>Create and Share Prompt Templates</strong></td>
    <td><strong>Compare output from different models</strong></td>
  </tr>
  <tr>
    <td><img src="https://github.com/datasiensai/terraform-azure-prisegpt/blob/main/assets/PromptTemplates.png" alt="Create and Share Prompt Templates" style="max-width: 100%; height: auto;"></td>
    <td><img src="https://github.com/datasiensai/terraform-azure-prisegpt/blob/main/assets/ModelComparison.png" alt="Compare output from different models" style="max-width: 100%; height: auto;"></td>
  </tr>
</table>

## Contributing

Contributions are welcome. Please submit a pull request if you have any improvements or fixes. Make sure to follow the existing code style and add comments to your code explaining what it does.  

## License

This terraform module is licensed under the MIT License. See the LICENSE file for more details.  

## Support

If you encounter any issues or have any questions about this terraform module, please open an issue on GitHub. We'll do our best to respond as quickly as possible.  

## Acknowledgements

This terraform module is maintained by **DataSiens** to offer enterprises a ChatGPT like solution within their Azure VPC.
The code was in a major part borrowed from Marcel Lupo's project. You can find his GitHub repository [here](https://github.com/Pwd9000-ML).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1.0 |

## Modules

No modules.
