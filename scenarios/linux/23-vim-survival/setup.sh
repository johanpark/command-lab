#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
# nano 를 숨기고 vim 을 준비한다 (vim-tiny 를 vim 이라는 이름으로도)
[ -e /usr/bin/nano ] && mv /usr/bin/nano /usr/bin/.nano-hidden
ln -sf "$(readlink -f /usr/bin/vim.tiny)" /usr/local/bin/vim
printf 'set nocompatible\nset backspace=indent,eol,start\nset ruler\nset showmode\n' > "$H/.vimrc"
cat > "$H/app.conf" <<'CONF'
# 쇼핑몰 서버 설정
name = shop
port = 8080
debug = true
workers = 4
log_level = info
CONF
give "$H/app.conf" "$H/.vimrc"
