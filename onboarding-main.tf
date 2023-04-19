# Below data resources gets "Microsoft Graph" data.
data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

resource "azuread_application" "cloudguard-app" {
  display_name     = "cloudguard-connect"

  web {
    redirect_uris = [lookup(var.chkp-account-region-list, var.chkp-account-region)[0]]
  }

  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.application_id # Microsoft Graph
/*
    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    } */
    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Reports.Read.All"]
      type = "Scope"
    }
    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["Directory.Read.All"]
      type = "Scope"
    }
  }
}
resource "azuread_application_password" "cloudguard-app-key" {
  display_name = "cloudguard-app-key"
  end_date_relative     = "8640h"     # one-year time frame
  application_object_id = azuread_application.cloudguard-app.object_id
}

resource "azuread_service_principal" "cloudguard-app-sp" {
  application_id = azuread_application.cloudguard-app.application_id
}

resource "azuread_service_principal_delegated_permission_grant" "cloudguard-app-admingrant" {
  claim_values = ["Directory.Read.All", "Reports.Read.All", "Policy.Read.All", "AccessReview.Read.All"]
  resource_service_principal_object_id = data.azuread_service_principal.msgraph.object_id
  service_principal_object_id          = azuread_service_principal.cloudguard-app-sp.object_id
}

data "azurerm_subscriptions" "available" {}

resource "azurerm_role_assignment" "cloudguard-app-reader-role-assign" {
  count = length(data.azurerm_subscriptions.available.subscriptions)

  scope = data.azurerm_subscriptions.available.subscriptions[count.index].id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.cloudguard-app-sp.object_id
}

resource "azurerm_role_definition" "cloudguard-app-custom-role" {
  count = length(data.azurerm_subscriptions.available.subscriptions)

  name        = "CloudGuard Additional Permissions Role"
  description = "Action permissions for CloudGuard"
  scope = data.azurerm_subscriptions.available.subscriptions[count.index].id
  assignable_scopes = [data.azurerm_subscriptions.available.subscriptions[count.index].id]
  permissions {
    actions     = ["Microsoft.Web/sites/config/list/Action"]
    not_actions = []
  }
}
resource "azurerm_role_assignment" "cloudguard-app-custom-role-assign" {
  count = length(data.azurerm_subscriptions.available.subscriptions)

  scope = data.azurerm_subscriptions.available.subscriptions[count.index].id
  role_definition_id   = azurerm_role_definition.cloudguard-app-custom-role[count.index].role_definition_resource_id
  principal_id         = azuread_service_principal.cloudguard-app-sp.object_id
}

resource "dome9_cloudaccount_azure" "connect-azure-subscription" {
  for_each = {for subscription in toset(data.azurerm_subscriptions.available.subscriptions) : subscription.display_name => subscription }

  operation_mode         = "Read"
  tenant_id              = var.azure-tenant
  client_id              = azuread_application.cloudguard-app.application_id
  client_password        = azuread_application_password.cloudguard-app-key.value
  name                   = each.value.display_name
  subscription_id        = each.value.subscription_id

  depends_on = [azurerm_role_assignment.cloudguard-app-custom-role-assign, azurerm_role_assignment.cloudguard-app-reader-role-assign]
}