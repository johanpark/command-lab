#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e

port=$(rand_int 15000 15999)
secret_set port "$port"

W="$H/webapp"
mkdir -p "$W"/{src,public,logs}
echo "console.log('server');" > "$W/src/server.js"
echo "<h1>Hello</h1>" > "$W/public/index.html"
echo "[INFO] starting..." > "$W/logs/app.log"
echo "# webapp" > "$W/README.md"
printf 'APP_NAME=webapp\nDB_HOST=db.internal\nDB_PORT=%s\nDB_USER=app\n' "$port" > "$W/.env"
printf 'APP_NAME=webapp\nDB_HOST=localhost\nDB_PORT=5432\nDB_USER=changeme\n' > "$W/.env.example"
printf 'APP_NAME=webapp\nDB_HOST=old-db\nDB_PORT=3306\n' > "$W/.env.bak"
printf 'node_modules/\n.env\n' > "$W/.gitignore"
touch -d '2024-03-01 10:00' "$W/.env.bak"
touch -d '2024-01-15 09:00' "$W/.env.example"
give "$W"
