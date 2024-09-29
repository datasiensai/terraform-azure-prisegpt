# Module: PriseGPT - ChatGPT for the Enterprise

## Current Version 1.x

Version **1.x.** LibreChat on Azure with following features
- Chat History (with CosmosDB)
- Chat with Files (with Azure Database for PostgreSQL Flexible Server)
- Artifacts similar to Claude to render code directly in chat window

## Coming next - Feature development

### v1.1.x (in development)

- [ ] Support for Models available on demand via Azure AI Studio


### v1.0.x (current)

- [x] LibreChat on Azure with following features
- [x] Chat History (with CosmosDB)
- [x] Chat with Files (with Azure Database for PostgreSQL Flexible Server)
- [x] Artifacts similar to Claude to render code directly in chat window


## Introduction

Under **OpenAI's** terms when using the public version of **ChatGPT**, any questions you pose—referred to as **"prompts"**—may contribute to the further training of OpenAI's Large Language Model (LLM). Given this, it's crucial to ask: Are you comfortable with this precious data flow leaving your organization? If you're a decision-maker or hold responsibility over your organization's security measures, what steps are you taking to ensure proprietary information remains confidential?  

An effective solution lies in utilising a hosted version of the popular LLM on **Azure OpenAI**. While there are numerous advantages to Azure OpenAI, I'd like to spotlight two:

- **Data Privacy**: By hosting OpenAI's models on Azure, your prompts will never serve as a source for training the LLM. It's simply a self-contained version running on Azure tailored for your use.

- **Enhanced Security**: Azure OpenAI offers robust security measures, from the capability to secure specific endpoints to intricate role-based access controls.
For a deeper dive, refer to this [Microsoft Learn article](https://learn.microsoft.com/en-us/azure/ai-services/openai/overview/?wt.mc_id=DT-MVP-5004771).  

While Azure OpenAI does come with a cost, it's highly affordable—often, a conversation costs under 10 cents. You can review Azure [OpenAI's pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/) details here.

## Architecture Diagram

![PriseGPT Azure Architecture](https://raw.githubusercontent.com/datasiensai/prisegpt/main/assets/PriseGPT_Azure_Architecture.jpg)

## Examples

- [Public Deployment with Custom Domain and IP Whitelisting](https://github.com/datasiensai/prisegpt/tree/main/examples/public_deployment_with_custom_domain)

## Screens

### Artifacts Like Claude

![Artifacts Like Claude](https://github.com/datasiensai/prisegpt/raw/main/assets/artifacts_like_claude.png)

### Chat with Files

![Chat with Files](https://github.com/datasiensai/prisegpt/raw/main/assets/chat_with_files.png)

### Create and Share Prompt Templates

![Create and Share Prompt Templates](https://github.com/datasiensai/prisegpt/raw/main/assets/create_and_share_prompt_templates.png)

### Compare output from different models

![Compare output from different models](https://github.com/datasiensai/prisegpt/raw/main/assets/compare_output_from_different_models.png)

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
