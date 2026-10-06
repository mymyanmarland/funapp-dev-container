# Funapp DevBox — Complete Development Environment
#
# All-in-one container for Funapp's tech stacks:
#   Stack 1 — Next.js 16 + Prisma + TypeScript
#   Stack 2 — Express 5 + TypeScript + Drizzle + PostgreSQL / React 19 + Vite
#   Stack 4 — React 19 + Vite + Tailwind CSS v4
#   Stack 5 — Flask / FastAPI + gunicorn + nginx + PostgreSQL
#
# Designed primarily for VS Code Dev Containers.
# Inspired by the dev-container pattern (eimg/fairway-dev-container).

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# ---------- Base dev tools ----------
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates lsb-release apt-transport-https \
        git curl wget unzip zip nano tree build-essential pkg-config \
        zsh sudo gnupg && \
    rm -rf /var/lib/apt/lists/*

# ---------- Oh My Zsh + dev prompt ----------
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
RUN echo 'export PS1="📦 funapp-dev $PS1"' >> /root/.zshrc && \
    chsh -s /bin/zsh root

# ---------- Node.js 22 (Stacks 1, 2, 4) ----------
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g pnpm yarn pm2 typescript ts-node nodemon prettier eslint && \
    rm -rf /var/lib/apt/lists/*

# ---------- Python 3 (Stack 5) ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv && \
    pip3 install --no-cache-dir --break-system-packages gunicorn flask && \
    rm -rf /var/lib/apt/lists/*

# ---------- GitHub CLI ----------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# ---------- PostgreSQL 16 (Stacks 1, 2, 5) ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
        postgresql-16 postgresql-client-16 && \
    mkdir -p /postgres/data && chown -R postgres:postgres /postgres && \
    rm -rf /var/lib/apt/lists/*

# ---------- Redis 7 ----------
RUN apt-get update && apt-get install -y --no-install-recommends redis-server && \
    mkdir -p /redis/data && chown -R redis:redis /redis && \
    rm -rf /var/lib/apt/lists/*

# ---------- nginx (Stack 4 static serving, Stack 5 reverse proxy) ----------
RUN apt-get update && apt-get install -y --no-install-recommends nginx && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -rf /var/lib/apt/lists/*
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY dashboard/index.html /var/www/html/index.html

# ---------- Entrypoint & service helpers ----------
COPY scripts/service-setup.sh /usr/local/bin/service-setup.sh
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/service-setup.sh /usr/local/bin/entrypoint.sh

# Web + common dev-server ports (map from host as needed)
EXPOSE 80 3000 4000 5000 8000 8800

WORKDIR /workspaces

CMD ["/usr/local/bin/entrypoint.sh"]
