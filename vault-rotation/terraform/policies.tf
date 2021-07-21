resource "vault_policy" "rotate_linux" {
  name   = "rotate_linux"
  policy = file("./policies/rotate_linux.hcl")
}

resource "vault_policy" "linux_admin" {
  name   = "linux_admin"
  policy = file("./policies/linux_admin.hcl")
}