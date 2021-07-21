resource "vault_password_policy" "linux_hosts" {
  name = "linux_hosts"
  policy = file("./password_policies/linux_hosts.hcl")
}