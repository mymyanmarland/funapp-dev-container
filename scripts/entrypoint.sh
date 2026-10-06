#!/bin/bash
# Funapp DevBox entrypoint — starts all services, then keeps the container alive.
set -e

source /usr/local/bin/service-setup.sh

start_postgres
start_redis
start_nginx

echo ""
echo "✅ Funapp DevBox ready!"
echo "   🐘 PostgreSQL : localhost:5432  (user: dev / password: dev / db: devdb)"
echo "   🔴 Redis      : localhost:6379"
echo "   🌐 Dashboard  : http://localhost:8800  (run with -p 8800:80)"
echo "   💻 Node       : $(node --version)   🐍 Python: $(python3 --version)"
echo ""

# VS Code Dev Containers attach their own process; for `docker run`
# keep the container alive. Interactive shells get zsh.
if [ -t 0 ]; then
    exec zsh
else
    exec sleep infinity
fi
