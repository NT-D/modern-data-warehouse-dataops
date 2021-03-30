#!/usr/bin/env bash

set -e

DEPLOYMENT_PREFIX=${DEPLOYMENT_PREFIX:-}
AZURE_RESOURCE_GROUP_NAME=${AZURE_RESOURCE_GROUP_NAME:-}

# Variables
keyVaultName="${DEPLOYMENT_PREFIX}akv01"

storageAccountName="${DEPLOYMENT_PREFIX}asa01"

echo "Retrieving keys from storage account"
storageKeys=$(az storage account keys list --resource-group "$AZURE_RESOURCE_GROUP_NAME" --account-name "$storageAccountName")
storageAccountKey1=$(echo "$storageKeys" | jq -r '.[0].value')
storageAccountKey2=$(echo "$storageKeys" | jq -r '.[1].value')

echo "Storing keys in key vault"
az keyvault secret set -n "StorageAccountKey1" --vault-name "$keyVaultName" --value "$storageAccountKey1" --output none
az keyvault secret set -n "StorageAccountKey2" --vault-name "$keyVaultName" --value "$storageAccountKey2" --output none
echo "Successfully stored secrets StorageAccountKey1 and StorageAccountKey2"

# # Create ADB secret scope backed by Key Vault
# adbGlobalToken=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --output json | jq -r .accessToken)
# echo "Got adbGlobalToken=\"${adbGlobalToken:0:20}...${adbGlobalToken:(-20)}\""
# azureApiToken=$(az account get-access-token --resource https://management.core.windows.net/ --output json | jq -r .accessToken)
# echo "Got azureApiToken=\"${azureApiToken:0:20}...${azureApiToken:(-20)}\""

# keyVaultId=$(echo "$akvArmOutput" | jq -r '.properties.outputs.keyvault_id.value')
# keyVaultUri=$(echo "$akvArmOutput" | jq -r '.properties.outputs.keyvault_uri.value')

# adbId=$(az databricks workspace show --resource-group "$AZURE_RESOURCE_GROUP_NAME" --name "$adbWorkspaceName" --query id --output tsv)
# adbWorkspaceUrl=$(az databricks workspace show --resource-group "$AZURE_RESOURCE_GROUP_NAME" --name "$adbWorkspaceName" --query workspaceUrl --output tsv)

# authHeader="Authorization: Bearer $adbGlobalToken"
# adbSPMgmtToken="X-Databricks-Azure-SP-Management-Token:$azureApiToken"
# adbResourceId="X-Databricks-Azure-Workspace-Resource-Id:$adbId"

# createSecretScopePayload="{
#   \"scope\": \"$scopeName\",
#   \"scope_backend_type\": \"AZURE_KEYVAULT\",
#   \"backend_azure_keyvault\":
#   {
#     \"resource_id\": \"$keyVaultId\",
#     \"dns_name\": \"$keyVaultUri\"
#   },
#   \"initial_manage_principal\": \"users\"
# }"
# echo "$createSecretScopePayload" | curl -sS -X POST -H "$authHeader" -H "$adbSPMgmtToken" -H "$adbResourceId" \
#     --data-binary "@-" "https://${adbWorkspaceUrl}/api/2.0/secrets/scopes/create"