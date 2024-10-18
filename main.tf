locals {
  admins = {
    for k,v in split(",", trimspace(var.entity_name)) : k => v
  }
}


## VAULT
data "vault_auth_backends" "Active_Directory" {
  type = "oidc"
}

resource "vault_namespace" "child_namespace" {
  path = var.namespace_path
}

resource "vault_identity_entity" "namespace_admin" {
  for_each = local.admins
  name     = each.value
  policies = ["${vault_policy.namespace_admin_policy.name}"]
  metadata  = {
    email = each.value
  }
  external_policies = true

}

resource "vault_identity_entity_policies" "policies" {
  for_each = local.admins
  policies = [
    "${vault_policy.namespace_admin_policy.name}"
  ]
  exclusive = true
  entity_id = vault_identity_entity.namespace_admin[each.key].id
}

resource "vault_identity_entity_alias" "entity_alias" {
  for_each = local.admins
  name           = vault_identity_entity.namespace_admin[each.key].name
  mount_accessor = data.vault_auth_backends.Active_Directory.accessors[0]
  canonical_id   = vault_identity_entity.namespace_admin[each.key].id
}

resource "vault_policy" "namespace_admin_policy" {
  name   = "${var.namespace_path}-policy"
  policy = <<EOT
# Manage namespaces
path "sys/namespaces/*" {
   capabilities = ["list"]
}

path "${vault_namespace.child_namespace.path}/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage namespaces
path "${vault_namespace.child_namespace.path}/sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "${vault_namespace.child_namespace.path}/+/sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage policies
path "${vault_namespace.child_namespace.path}/sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "${vault_namespace.child_namespace.path}/+/sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List policies
path "${vault_namespace.child_namespace.path}/sys/policies/acl" {
  capabilities = ["list"]
}
path "${vault_namespace.child_namespace.path}/+/sys/policies/acl" {
  capabilities = ["list"]
}
# Enable and manage secrets engines
path "${vault_namespace.child_namespace.path}/sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "${vault_namespace.child_namespace.path}/+/sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
# List available secrets engines
path "${vault_namespace.child_namespace.path}/sys/mounts" {
  capabilities = ["read"]
}
path "${vault_namespace.child_namespace.path}/+/sys/mounts" {
  capabilities = ["read"]
}
EOT
}
