#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A=/srv/app; D="$H/downloads"
rm -rf "$A" "$D"; mkdir -p "$A/releases" "$D"
mkrel() { # 폴더 버전
  mkdir -p "$1"/{bin,config,public}
  printf '#!/bin/sh\necho "app %s starting"\n' "$2" > "$1/bin/start.sh"; chmod 755 "$1/bin/start.sh"
  printf '#!/bin/sh\necho migrate\n' > "$1/bin/migrate.sh"; chmod 755 "$1/bin/migrate.sh"
  echo "$2" > "$1/VERSION"
  echo "PORT=8080" > "$1/config/app.env.example"
  echo "<h1>app $2</h1>" > "$1/public/index.html"
}
mkrel "$A/releases/2.3.9" 2.3.9
ln -s releases/2.3.9 "$A/current"
T=$(mktemp -d)
mkrel "$T/app-2.4.0" 2.4.0
tar czf "$D/app-2.4.0.tar.gz" -C "$T" app-2.4.0
mkdir -p "$T/plugins"
plugins=$(rand_pick "auth cache metrics" "auth search export" "cache export sso")
for p in $plugins; do printf 'name: %s\nversion: 1.%s\n' "$p" "$(rand_int 0 9)" > "$T/plugins/$p.yml"; done
echo "플러그인 설명" > "$T/plugins/README.plugins"
(cd "$T/plugins" && tar czf "$D/plugins.tar.gz" *)
tar tzf "$D/plugins.tar.gz" > /opt/cmdlab/secret/plugins
find "$A/releases/2.3.9" -type f -exec md5sum {} + > /opt/cmdlab/secret/old
rm -rf "$T"
chown -R "$LEARNER:$LEARNER" "$A" "$D"
