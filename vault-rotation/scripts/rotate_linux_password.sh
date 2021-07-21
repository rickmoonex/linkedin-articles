#!/bin/bash
# Script for rotating passwords on the local linux machine
# Make sure and store VAULT_TOKEN and VAULT_ADDR as environment variables

# Check for usage
if [[ $# -ne 1 ]]; then
    echo "Please provide a username.    Usage:"
    echo "$0 root"
    exit 1
fi

USERNAME=$1

# Make sure given user exists on the local machine
if ! [[ $(id $USERNAME) ]]; then
    echo "$USERNAME does not exists!"
    exit 1
fi

# Renew Vault token
curl -sS --fail -X POST -H "X-Vault-Token: $VAULT_TOKEN" ${VAULT_ADDR}/v1/auth/token/renew-self | grep -q 'lease_duration'
retval=$?
if [[ $retval -ne 0 ]]; then
    echo "Error renewing Vault token lease!"
fi

# Request new password from Vault
NEWPASS=$(curl -sS --fail -X GET -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" ${VAULT_ADDR}/v1/sys/policies/password/linux_hosts/generate | jq -r '.data|.password')

# Create the JSON payload to write to Vault
JSON="{ \"options\": { \"max_versions\": 12 }, \"data\": { \"${USERNAME}\": \"$NEWPASS\" } }"

# First commit the new password to Vault, then capture the exit status
curl -sS --fail -X POST -H "X-Vault-Token: $VAULT_TOKEN" --data "$JSON" ${VAULT_ADDR}/v1/systemcreds/data/linux/$(hostname) | grep -q 'request_id'
retval=$?
if [[ $retval -eq 0 ]]; then
  # After saving the password to Vault, update it on the host
  echo "$USERNAME:$NEWPASS" | sudo chpasswd
  retval=$?
    if [[ $retval -eq 0 ]]; then
      echo -e "${USERNAME}'s password was stored in Vault and updated locally."
    else
      echo "Error: ${USERNAME}'s password was stored in Vault but *not* updated locally."
    fi
else
  echo "Error saving new password to Vault. Local password will remain unchanged."
  exit 1
fi
