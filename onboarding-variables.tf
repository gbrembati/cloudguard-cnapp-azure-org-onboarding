// --- Azure Provider ---
variable "azure-client-id" {
  description = "Insert your application client-id"
  type = string
  sensitive = true    
} 
variable "azure-client-secret" {
  description = "Insert your application client-secret"
  type = string
  sensitive = true
}
variable "azure-subscription" {
  description = "Insert your subscription-id"
  type = string
  sensitive = true
}
variable "azure-tenant" {
  description = "Insert your active-directory-id"
  type = string
  sensitive = true
}

// --- CloudGuard Provider ---
variable "cspm-key-id" {
  description = "Insert your API Key ID"
  type = string
}
variable "cspm-key-secret" {
  description = "Insert your API Key Secret"
  type = string
  sensitive = true
}
variable "chkp-account-region-list" {
  description = "List of CloudGuard Account ID and API Endpoint"
  default = {
    America   = ["https://central.dome9.com/","https://api.dome9.com/v2/"],
    Europe    = ["https://central.eu1.dome9.com/","https://api.eu1.dome9.com/v2/"],
    Australia = ["https://central.ap2.dome9.com/","https://api.ap2.dome9.com/v2/"]
  }
}
locals {
  allowed_region_name = ["Europe","America","Australia",]
  validate_region_name = index(local.allowed_region_name, var.chkp-account-region)
}
variable "chkp-account-region" {
  description = "Insert your Cloudguard Account residency location"
  type = string
}