### VAULT
## vault hostname은 TFE에 private 네트워크 망이 연결된걸로 가정하고 지정 사용

# variable set
variable "vault_hostname" {
  default = ""
  description = "Vault Cluster의 hostname, Private url 사용"
}

# variable set
variable "admin_token" {
  default = ""
  description = "Vault의 관리자 TOKEN"
}


#required
variable "namespace_path" {
  # default = "prj1-other-region-namespace"
  description = "새로 생성할 vault namespace path"
}
# required
variable "entity_name" {
  # default = "admin-#123"
  description = "AD와 연동된 사용자 이메일 입력, vault에 client 사전생성용도"
}