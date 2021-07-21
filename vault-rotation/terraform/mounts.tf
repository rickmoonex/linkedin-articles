resource "vault_mount" "systemcreds" {
  path = "systemcreds"
  type = "kv-v2"
}