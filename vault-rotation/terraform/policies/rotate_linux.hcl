# Allow hosts to write new passwords
path "systemcreds/data/linux/*" {
    capabilities = ["create", "update"]
}

# Allow hosts to generate new passwords
path "sys/policies/password/linux_hosts/generate" {
    capabilities = ["read"]
}