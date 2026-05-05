# dbgpt — Azure AI Foundry on AKS

> **LLM-powered data assistant** connected to Azure AI Foundry models,
> deployed on Azure Kubernetes Service.

---

## Repository layout

```
├── Dockerfile                  # Container image definition
├── docker-entrypoint.sh        # Startup script — injects secrets into config
├── config.toml                 # App config template (env var placeholders)
├── .dockerignore
│
├── namespace.yaml              # K8s namespace
├── secret.yaml                 # K8s Secret (fill values before applying)
├── configmap.yaml              # K8s ConfigMap (mounts config.toml)
├── pvc.yaml                    # Persistent storage claims
├── deployment.yaml             # K8s Deployment
├── service.yaml                # K8s Service + Ingress template
│
└── .github/
    └── workflows/
        └── deploy-dbgpt.yml    # GitHub Actions CI/CD pipeline
```

---

## For the infra team

See **[INFRA_BRIEF.md](./INFRA_BRIEF.md)** for:
- Full AKS deployment instructions
- Persistent storage requirements
- Secret values needed
- Network/firewall requirements

---

## For developers — local Docker test

Test the image locally before pushing:

```bash
# Build
docker build -t dbgpt-azure:local .

# Run with env vars (replace values)
docker run -p 5670:5670 \
  -e AZURE_OPENAI_ENDPOINT="https://YOUR-RESOURCE.openai.azure.com/" \
  -e AZURE_OPENAI_API_KEY="your-api-key" \
  -e AZURE_OPENAI_API_VERSION="2024-02-01" \
  -e DBGPT_ENCRYPT_KEY="any-random-32-char-string" \
  -e MYSQL_HOST="your-mysql-host" \
  -e MYSQL_PASSWORD="your-password" \
  dbgpt-azure:local

# Open http://localhost:5670
```

> **Tip:** To use SQLite instead of MySQL (no DB server needed for local testing),
> edit `config.toml` and switch the `[service.web.database]` section to `type = "sqlite"`.

---

## Environment variables reference

| Variable | Required | Description |
|---|---|---|
| `AZURE_OPENAI_ENDPOINT` | ✅ | `https://YOUR-RESOURCE.openai.azure.com/` |
| `AZURE_OPENAI_API_KEY` | ✅ | API key from Azure Portal → AI Foundry |
| `AZURE_OPENAI_API_VERSION` | ✅ | e.g. `2024-02-01` |
| `DBGPT_ENCRYPT_KEY` | ✅ | Random 32-char string for internal encryption |
| `MYSQL_HOST` | ⚠️ | MySQL server hostname or IP (not needed for SQLite) |
| `MYSQL_PASSWORD` | ⚠️ | MySQL password (not needed for SQLite) |

---

## Azure AI Foundry model deployment names

Update `config.toml` if your Azure deployment names differ:

| Config key | Default value | Change to your deployment name |
|---|---|---|
| `[[models.llms]] name` | `gpt-4o` | e.g. `my-gpt4o-deployment` |
| `[[models.embeddings]] name` | `text-embedding-3-large` | e.g. `my-embedding-deployment` |
