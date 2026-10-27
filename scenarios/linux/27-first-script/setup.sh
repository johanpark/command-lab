#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
P="$H/projects/site"; mkdir -p "$P/css"
echo "<h1>site</h1>" > "$P/index.html"; echo "body{}" > "$P/css/main.css"
mkdir -p "$H/projects/blog"; echo "# blog" > "$H/projects/blog/README.md"
give "$H/projects"
