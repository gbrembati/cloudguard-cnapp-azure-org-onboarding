# CloudGuard CNAPP Azure Tenant Terraform Onboarding
This Terraform project is intended to be used to onboard an entire Azure Tenant in one shot.     
What it does is configure, via **Terraform**, an existing CloudGuard CSPM Portal and Azure environment that has multiple subscriptions.      
 
## How to start?
You would need to have a CloudGuard tenant, you can create one via *Infinity Portal* by clicking: [Register Here](https://portal.checkpoint.com/create-account)

## Get API credentials in your CloudGuard CNAPP Portal
Then you will need to get the API credentials you will use with Terraform to onboard the accounts.

![Architectural Design](/zimages/create-cnapp-serviceaccount.jpg)

Remember to copy these two values, you will need to enter them in the *.tfvars* file later on.

## Prerequisite
Before you proceed, if you would like to create Azure configuration manually and only configure CloudGuard CNAP Platform with terraform, please check the simplified version of this onboarding at [gbrembati / cloudguard-cnapp-azure-org-onboarding-simple](https://github.com/gbrembati/cloudguard-cnapp-azure-org-onboarding-simple).    

You would need to have proper permission and authentication in Azure. This can be achieved either by specifying the authentication parameters using your service-principal authentication (as described below) or using other means of authenticating as described in [AzureRM Terraform Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).

## How to use it
The only thing that you need to do is change the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
azure-client-id     = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-client-secret = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-subscription  = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-tenant        = "xxxxx-xxxxx-xxxxx-xxxxx"

cspm-key-id         = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
cspm-key-secret     = "xxxxxxxxxxxxxxxxxxxx"

chkp-account-region = "Europe"     // Use either Europe / America or Australia
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files. Here you will also be able to find the descriptions that explain what each variable is used for.