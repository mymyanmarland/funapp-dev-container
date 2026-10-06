#!/bin/bash
# Funapp DevBox — shared service helpers.
# Sourced by entrypoint.sh; safe to re-run (idempotent).
set -e

PGDATA=/postgres/data
PGBIN=/usr/lib/postgresql/16/bin

start_postgres() {
    if [ ! -s "$PGDATA/PG_VERSION" ]; then
        echo "📦 Initializing PostgreSQL data directory..."
        mkdir -p "$PGDATA"
        chown -R postgres:postgres "$PGDATA"
        su postgres -c "$PGBIN/initdb -D $PGDATA -E UTF8 --auth=trust" > /tmp/pg-init.log 2>&1
    fi
    if ! su postgres -c "$PGBIN/pg_ctl -D $PGDATA status" > /dev/null 2>&1; then
        echo "🐘 Starting PostgreSQL..."
        su postgres -c "$PGBIN/pg_ctl -D $PGDATA -l /tmp/postgres.log start"
        # Dev role + database (idempotent; failures mean they already exist)
        su postgres -c "$PGBIN/psql -c \"CREATE ROLE dev WITH LOGIN PASSWORD 'dev' SUPERUSER;\"" > /dev/null 2>&1 || true
        su postgres -c "$PGBIN/createdb -O dev devdb" > /dev/null 2>&1 || true
    fi
}

start_redis() {
    if ! redis-cli ping > /dev/null 2>&1; then
        echo "🔴 Starting Redis..."
        mkdir -p /redis/data
        chown -R redis:redis /redis
        redis-server --daemonize yes --dir /redis/data --logfile /tmp/redis.log
    fi
}

start_nginx() {
    echo "🌐 Starting nginx..."
    nginx -t -q
    # `nginx` (not daemon off): entrypoint keeps the container alive separately
    nginx 2>/dev/null || nginx -s reload 2>/dev/null || true
}
