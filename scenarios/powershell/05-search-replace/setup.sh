#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
C="$H/configs"; mkdir -p "$C"
: > /opt/cmdlab/secret/leaks
for s in billing orders search auth notify reports; do
  {
    echo "[service]"
    echo "name=$s"
    echo "endpoint=http://$s.internal:$(rand_int 8000 8999)/api"
    echo "docs=http://wiki.local/$s"
    echo "[database]"
    echo "user=$s"
    if [ $((RANDOM % 2)) -eq 0 ]; then echo "password=$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')"; echo "$s.ini" >> /opt/cmdlab/secret/leaks
    else echo "# password=  (vault 에서 주입)"; echo "password_ref=vault://$s/db"; fi
  } > "$C/$s.ini"
done
# 최소 하나는 평문 비밀번호가 있게
if [ ! -s /opt/cmdlab/secret/leaks ]; then echo "password=letmein" >> "$C/billing.ini"; echo billing.ini > /opt/cmdlab/secret/leaks; fi
echo "http 로 시작하는 주소 메모" > "$C/README.txt"
give "$C"
rm -rf /opt/cmdlab/secret/expected && cp -r "$C" /opt/cmdlab/secret/expected
sed -i 's#http://#https://#g' /opt/cmdlab/secret/expected/*.ini
