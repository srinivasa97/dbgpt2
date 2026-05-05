#!/bin/sh
# ============================================================
# docker-entrypoint.sh
# Substitutes environment variables into the config template
# at container startup, then launches dbgpt.
# ============================================================
set -e

CONFIG_TEMPLATE="/app/configs/dbgpt-proxy-azure.toml.template"
CONFIG_OUT="/app/configs/dbgpt-proxy-azure.toml"

echo "[entrypoint] Generating config from template..."

# Validate required env vars are set
MISSING=""
for VAR in AZURE_OPENAI_ENDPOINT AZURE_OPENAI_API_KEY AZURE_OPENAI_API_VERSION; do
  eval VAL=\$$VAR
  if [ -z "$VAL" ]; then
    MISSING="$MISSING $VAR"
  fi
done

if [ -n "$MISSING" ]; then
  echo "[entrypoint] ERROR: Missing required environment variables:$MISSING"
  echo "[entrypoint] These must be set via Kubernetes Secret or docker run -e"
  exit 1
fi

# Substitute env vars into config template
# Using envsubst which is available in Alpine/Debian base images
envsubst < "$CONFIG_TEMPLATE" > "$CONFIG_OUT"

echo "[entrypoint] Config written to $CONFIG_OUT"
echo "[entrypoint] Azure endpoint: $AZURE_OPENAI_ENDPOINT"
echo "[entrypoint] API version:    $AZURE_OPENAI_API_VERSION"
echo "[entrypoint] MySQL host:     ${MYSQL_HOST:-not set (using SQLite)}"
echo "[entrypoint] Starting dbgpt webserver..."

exec dbgpt start webserver --config "$CONFIG_OUT"
