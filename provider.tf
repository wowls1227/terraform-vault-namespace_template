terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

# provider "hcp" {

# }
provider "vault" {
  address   = var.vault_hostname
  token     = var.admin_token
  namespace = "admin"
}

# 