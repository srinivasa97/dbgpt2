# ============================================================
# dbgpt — Production Docker Image
# Base: official eosphorosai/dbgpt image
# LLM Backend: Azure AI Foundry (Azure OpenAI)
# ============================================================

FROM eosphorosai/dbgpt:latest

# Labels for traceability
LABEL maintainer="srinivasa97"
LABEL description="dbgpt with Azure AI Foundry proxy backend"
LABEL org.opencontainers.image.source="https://github.com/srinivasa97/dbgpt"

# ---- Runtime environment ----
ENV DBGPT_LANG=en \
    LANGUAGE=en \
    # These are placeholders — override via K8s Secret / env vars at runtime.
    # Do NOT hardcode real values here.
    AZURE_OPENAI_ENDPOINT="" \
    AZURE_OPENAI_API_KEY="" \
    AZURE_OPENAI_API_VERSION="2024-02-01" \
    MYSQL_HOST="" \
    MYSQL_PASSWORD=""

# ---- Copy config into image ----
# The config references ${AZURE_OPENAI_ENDPOINT} etc. which are substituted
# at container startup via the entrypoint script below.
COPY config.toml /app/configs/dbgpt-proxy-azure.toml.template

# ---- Entrypoint: substitute env vars into config, then start server ----
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 5670

ENTRYPOINT ["/app/docker-entrypoint.sh"]
