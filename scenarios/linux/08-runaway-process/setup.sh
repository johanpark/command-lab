#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
name=$(rand_pick data-sync img-resizer cache-warmer report-gen)
secret_set name "$name"

mk() { printf '#!/bin/bash\n%s\n' "$2" > "/usr/local/bin/$1"; chmod 755 "/usr/local/bin/$1"; }
mk web-server 'while :; do sleep 30; done'
mk log-shipper 'while :; do sleep 5; done'
mk backup-agent 'while :; do sleep 60; done'
mk "$name" 'while :; do :; done'

spawn_bg /usr/local/bin/web-server
spawn_bg /usr/local/bin/log-shipper
spawn_bg /usr/local/bin/backup-agent
spawn_bg /usr/local/bin/"$name"
sleep 1
