#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
id deploy >/dev/null 2>&1 || useradd -m -s /bin/bash deploy
rm -rf /home/deploy/.ssh "$H/.ssh"
chmod 755 /home/deploy
