<p align="center">
  <img src="assets/banner.png" alt="Funapp DevBox — One container. Every stack." width="100%">
</p>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=22&pause=1000&color=E11D2E&center=true&vCenter=true&width=640&lines=One+container.+Every+stack.;Node+22+%7C+Python+3+%7C+PostgreSQL+16+%7C+Redis+7;Code+in+2+minutes.+No+setup+hell." alt="typing animation" />
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/mymyanmarland/funapp-devbox?style=flat-square" alt="MIT"></a>
  <img src="https://img.shields.io/github/stars/mymyanmarland/funapp-devbox?style=flat-square" alt="stars">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square" alt="PRs welcome">
  <img src="https://img.shields.io/badge/docker-ready-2496ED?style=flat-square&logo=docker&logoColor=white" alt="docker ready">
  <img src="https://img.shields.io/badge/vscode-devcontainer-007ACC?style=flat-square&logo=visualstudiocode&logoColor=white" alt="vscode devcontainer">
</p>

<p align="center">
  <b>Complete Docker development environment for Funapp's tech stacks.</b><br>
  Open a project, hit <i>Reopen in Container</i>, start coding in 2 minutes.<br>
  No more <i>"works on my machine"</i>. 🎉
</p>

> မြန်မာလို: VS Code မှာ project ဖွင့်ပြီး "Reopen in Container" နှိပ်လိုက်တာနဲ့ Node, PostgreSQL, Redis, Python အကုန်အဆင်သင့် — setup လုပ်စရာမလို။

<p align="center">
  <img src="assets/architecture.svg" alt="Funapp DevBox architecture" width="720">
</p>

## ✨ What's inside the box

| | Component | Version | Notes |
|---|---|---|---|
| 🖥️ | OS | Ubuntu 24.04 LTS | zsh + oh-my-zsh, `📦 funapp-dev` prompt |
| 💻 | Node.js | 22 | npm · pnpm · yarn · pm2 · typescript · ts-node · prettier · eslint |
| 🐍 | Python | 3.12 | pip · venv · gunicorn · flask |
| 🐘 | PostgreSQL | 16 | user `dev` / password `dev` / db `devdb` |
| 🔴 | Redis | 7.0 | `localhost:6379` |
| 🌐 | nginx | latest | dashboard on `:80`, reverse-proxy examples included |
| 🛠️ | Tools | — | git · gh · curl · nano · tree |

## 🧱 Supported stacks

| Stack | What it is | When to use it | Ready in the box |
|---|---|---|---|
| **Stack 1** | Next.js 16 + Prisma + TypeScript | Full web app, one codebase (frontend + backend together) | Node 22 · PostgreSQL · Prisma CLI via npx |
| **Stack 2** | Express 5 + TypeScript + Drizzle (API) + React 19 + Vite (frontend) | Separate backend API + frontend | Node 22 · PostgreSQL · Redis · Drizzle Kit via npx |
| **Stack 4** | React 19 + Vite + Tailwind CSS v4 | Frontend only, fast interactive UI | Node 22 · Vite via npm |
| **Stack 5** | Flask + gunicorn + nginx + PostgreSQL | Python web app / API | Python 3 · gunicorn · nginx · PostgreSQL |

> **Which one do I pick?** One codebase and want it simple → **Stack 1**. Need a separate API (mobile app later, etc.) → **Stack 2**. Only a beautiful frontend → **Stack 4**. You prefer Python → **Stack 5**.

## 🚀 Quick start

<details open>
<summary><b>VS Code Dev Container (recommended)</b></summary>
<br>

**Prerequisites:** VS Code + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) + Docker.

```bash
# 1. Add the DevBox config to your project
mkdir -p .devcontainer
curl -o .devcontainer/devcontainer.json \
  https://raw.githubusercontent.com/mymyanmarland/funapp-devbox/main/.devcontainer/devcontainer.json

# 2. Open your project
code .

# 3. Command Palette (Ctrl+Shift+P) → "Dev Containers: Reopen in Container"

# 4. Done! 🎉 PostgreSQL, Redis & nginx start automatically.
```

| Service | Address |
|---|---|
| 🌐 Dashboard | http://localhost:8800 |
| ⚛️ Next.js / Vite | http://localhost:3000 |
| 🔌 Express API | http://localhost:4000 |
| 🐍 Flask | http://localhost:5000 |
| 🐘 PostgreSQL | `postgresql://dev:dev@localhost:5432/devdb` |
| 🔴 Redis | `localhost:6379` |

</details>

<details>
<summary><b>Direct Docker</b></summary>
<br>

```bash
docker build -t funapp-devbox .
docker run -d --name devbox \
  -p 8800:80 -p 3000:3000 -p 4000:4000 -p 5000:5000 \
  -v "$PWD:/workspaces/app" \
  -v pgdata:/postgres/data \
  -v redisdata:/redis/data \
  funapp-devbox
```

Or copy [`with-compose/docker-compose.yml`](with-compose/docker-compose.yml) into your project → `docker compose up -d`.

</details>

## 📋 Stack guides — how to use each one

> All commands below run **inside the DevBox** (the container terminal). The database is already running — just point your `DATABASE_URL` at it:
> ```
> DATABASE_URL="postgresql://dev:dev@localhost:5432/devdb"
> ```

<details open>
<summary><b>Stack 1 — Next.js 16 + Prisma</b> · full web app in one codebase</summary>
<br>

```bash
# 1. Create the app
npx create-next-app@latest my-app
cd my-app

# 2. Set up the database (already running in the box)
npx prisma init
# → edit .env: DATABASE_URL="postgresql://dev:dev@localhost:5432/devdb"
# → edit prisma/schema.prisma: add your models

# 3. Create tables
npx prisma migrate dev --name init

# 4. Run it
npm run dev
# → open http://localhost:3000 🎉
```

Use for: admin panels, shops, dashboards — anything where frontend + backend live together.
</details>

<details>
<summary><b>Stack 2 — Express 5 API + Drizzle</b> · separate backend</summary>
<br>

```bash
# 1. Scaffold
mkdir my-api && cd my-api
npm init -y
npm i express drizzle-orm pg
npm i -D typescript @types/express @types/node @types/pg drizzle-kit tsx

# 2. .env file:
DATABASE_URL="postgresql://dev:dev@localhost:5432/devdb"

# 3. Write src/index.ts (Express app) + src/schema.ts (Drizzle tables), then:
npx drizzle-kit generate
npx drizzle-kit migrate

# 4. Run it
npx tsx src/index.ts
# → API live at http://localhost:4000 🎉
```

**Stack 2 frontend** (React 19 + Vite) — same steps as Stack 4 below, calling your API at `http://localhost:4000`.

Use for: backends that serve a mobile app or a separate frontend later.
</details>

<details>
<summary><b>Stack 4 — React 19 + Vite + Tailwind v4</b> · frontend only</summary>
<br>

```bash
# 1. Scaffold
npm create vite@latest my-app -- --template react-ts
cd my-app
npm i

# 2. Tailwind v4
npm i -D tailwindcss @tailwindcss/vite
# → vite.config.ts: import tailwindcss from '@tailwindcss/vite' and add tailwindcss() to plugins
# → src/index.css: add `@import "tailwindcss";` at the top

# 3. Run it (0.0.0.0 so the host browser can reach it)
npm run dev -- --host 0.0.0.0
# → open http://localhost:3000 🎉
```

Deploying? `npm run build` → serve the `dist/` folder with nginx (no Node server needed).
</details>

<details>
<summary><b>Stack 5 — Flask + gunicorn</b> · Python web app</summary>
<br>

```bash
# 1. Virtual environment
python3 -m venv venv
source venv/bin/activate

# 2. Install
pip install flask psycopg2-binary

# 3. Write app.py, e.g.:
#    from flask import Flask
#    app = Flask(__name__)
#    @app.route("/")
#    def hello(): return "Hello from DevBox!"

# 4. Run with gunicorn (production-grade, like the VPS)
gunicorn -b 127.0.0.1:5000 app:app
# → open http://localhost:5000 🎉
```

Want nginx in front (like production)? Uncomment the `/app/` example in `nginx/nginx.conf`.

Use for: Python APIs, data tools, anything where Python libraries matter.
</details>

## 🔧 Customization

**Verify files before building:**
```bash
python3 -m json.tool .devcontainer/devcontainer.json > /dev/null
bash -n scripts/entrypoint.sh && bash -n scripts/service-setup.sh
```

**Change port mapping** — edit `runArgs` in `.devcontainer/devcontainer.json`:
```json
"runArgs": ["-p", "8800:80", "-e", "MY_VAR=value"]
```

**Add VS Code extensions** — extend `customizations.vscode.extensions` in `.devcontainer/devcontainer.json`.

**nginx reverse proxy** — uncomment the examples in `nginx/nginx.conf` to proxy `/api/` → Express or `/app/` → gunicorn.

## 📁 File structure

```
.
├── Dockerfile                  # the image
├── .devcontainer/
│   └── devcontainer.json       # VS Code Dev Container config
├── assets/
│   ├── banner.png              # repo banner
│   └── architecture.svg        # animated architecture diagram
├── dashboard/
│   └── index.html              # status dashboard (nginx :80)
├── nginx/
│   └── nginx.conf              # minimal nginx + proxy examples
├── scripts/
│   ├── entrypoint.sh           # starts postgres, redis, nginx
│   └── service-setup.sh        # shared service helpers
└── with-compose/
    └── docker-compose.yml      # compose variant
```

Project files mount at `/workspaces/<project>` (Dev Container) or `/workspaces/app` (direct docker). Data persists in `/postgres/data` and `/redis/data` — mount volumes to keep it.

## ⚠️ Notes

- Container runs as **root** for development simplicity — dev only, never production.
- Change the default `dev`/`dev` PostgreSQL credentials for anything shared.
- `gh` and host `.gitconfig` can be bind-mounted for convenience (trusted environments only).

## 📄 License

MIT — see [LICENSE](LICENSE). Built with ❤️ by [Funapp](https://github.com/mymyanmarland).
