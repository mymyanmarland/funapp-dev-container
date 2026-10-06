# 📦 Funapp DevBox

**Complete development environment container for Funapp's tech stacks** — open a project and start coding in 2 minutes. No more "works on my machine".

> မြန်မာလို: VS Code မှာ project ဖွင့်ပြီး "Reopen in Container" နှိပ်လိုက်တာနဲ့ Node, PostgreSQL, Redis, Python အကုန်အဆင်သင့် — setup လုပ်စရာမလို။

## What's Included

| Component | Version | Notes |
|---|---|---|
| OS | Ubuntu 24.04 LTS | zsh + oh-my-zsh, `📦 funapp-dev` prompt |
| Node.js | 22 | npm · pnpm · yarn · pm2 · typescript · ts-node · prettier · eslint |
| Python | 3.12 | pip · venv · gunicorn · flask |
| PostgreSQL | 16 | dev user `dev` / password `dev` / db `devdb` |
| Redis | 7.0 | localhost:6379 |
| nginx | latest | dashboard on :80, reverse-proxy examples included |
| Tools | — | git · gh (GitHub CLI) · curl · nano · tree |

**Covers all Funapp stacks:**
- **Stack 1** — Next.js 16 + Prisma + TypeScript
- **Stack 2** — Express 5 + TypeScript + Drizzle + PostgreSQL · React 19 + Vite
- **Stack 4** — React 19 + Vite + Tailwind CSS v4
- **Stack 5** — Flask / FastAPI + gunicorn + nginx + PostgreSQL

## VS Code Dev Container (Recommended)

**Prerequisites:** VS Code with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers), plus Docker.

### Quick Start

```bash
# 1. Create .devcontainer in your project
mkdir -p .devcontainer
curl -o .devcontainer/devcontainer.json \
  https://raw.githubusercontent.com/mymyanmarland/funapp-dev-container/main/.devcontainer/devcontainer.json

# 2. Open your project in VS Code
code .

# 3. Command Palette → "Dev Containers: Reopen in Container"

# 4. Done! 🎉 PostgreSQL, Redis and nginx start automatically.
```

**Access services:**

| Service | URL / Address |
|---|---|
| Dashboard | http://localhost:8800 (auto-forwarded from nginx :80) |
| Next.js / Vite | http://localhost:3000 |
| Express API | http://localhost:4000 |
| Flask | http://localhost:5000 |
| PostgreSQL | `localhost:5432` — user `dev`, password `dev`, db `devdb` |
| Redis | `localhost:6379` |

Connection string example: `postgresql://dev:dev@localhost:5432/devdb`

## Direct Docker Usage

```bash
# Build
docker build -t funapp-devbox .

# Run (dashboard on http://localhost:8800)
docker run -d --name devbox \
  -p 8800:80 -p 3000:3000 -p 4000:4000 -p 5000:5000 \
  -v "$PWD:/workspaces/app" \
  -v pgdata:/postgres/data \
  -v redisdata:/redis/data \
  funapp-devbox
```

Or use the compose variant: copy [`with-compose/docker-compose.yml`](with-compose/docker-compose.yml) into your project and run `docker compose up -d`.

## Stack Recipes

**Stack 1 — new Next.js app:**
```bash
npx create-next-app@latest my-app && cd my-app
npx prisma init   # DATABASE_URL="postgresql://dev:dev@localhost:5432/devdb"
npm run dev       # → http://localhost:3000
```

**Stack 2 — Express API + Drizzle:**
```bash
npm init -y && npm i express drizzle-orm pg && npm i -D typescript @types/express @types/node drizzle-kit tsx
# DATABASE_URL="postgresql://dev:dev@localhost:5432/devdb"
npx tsx src/index.ts   # → http://localhost:4000
```

**Stack 4 — Vite React:**
```bash
npm create vite@latest my-app -- --template react-ts && cd my-app
npm i && npm run dev -- --host 0.0.0.0   # → http://localhost:3000
```

**Stack 5 — Flask:**
```bash
python3 -m venv venv && source venv/bin/activate
pip install flask
gunicorn -b 127.0.0.1:5000 app:app
```

## Customization

**Verify files before building** (same checks CI would run):
```bash
python3 -m json.tool .devcontainer/devcontainer.json > /dev/null
bash -n scripts/entrypoint.sh && bash -n scripts/service-setup.sh
```

**Change port mapping** — edit `runArgs` in `.devcontainer/devcontainer.json`:
```json
"runArgs": ["-p", "8800:80", "-e", "MY_VAR=value"]
```

**Add VS Code extensions** — add to `customizations.vscode.extensions` in `.devcontainer/devcontainer.json`.

**nginx reverse proxy** — uncomment the examples in `nginx/nginx.conf` to proxy `/api/` → Express or `/app/` → gunicorn.

## File Structure

```
.
├── Dockerfile                  # the image
├── .devcontainer/
│   └── devcontainer.json       # VS Code Dev Container config
├── dashboard/
│   └── index.html              # status dashboard (nginx :80)
├── nginx/
│   └── nginx.conf              # minimal nginx + proxy examples
├── scripts/
│   ├── entrypoint.sh           # starts postgres, redis, nginx
│   └── service-setup.sh        # shared service helpers
├── with-compose/
│   └── docker-compose.yml      # compose variant
└── .github/workflows/ci.yml    # JSON + shell + nginx sanity checks
```

**Project files** mount at `/workspaces/<project>` (Dev Container) or `/workspaces/app` (direct docker). **Data** persists in `/postgres/data` and `/redis/data` — mount volumes to keep it.

## Important Notes

- Container runs as **root** for development simplicity — dev only, never production.
- Change the default `dev`/`dev` PostgreSQL credentials for anything shared.
- `gh` and your host `.gitconfig` can be bind-mounted for convenience (trusted environments only).
- CI validates `devcontainer.json`, shell scripts and nginx config on every push.

## License

MIT — see [LICENSE](LICENSE). Built with ❤️ by [Funapp](https://github.com/mymyanmarland).
