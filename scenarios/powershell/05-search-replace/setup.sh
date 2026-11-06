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
    # billing 은 늘 평문, auth 는 늘 주석(함정), 나머지는 무작위 → 매번 두 경우가 다 나온다
    if [ "$s" = billing ] || { [ "$s" != auth ] && [ $((RANDOM % 2)) -eq 0 ]; }; then echo "password=$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')"; echo "$s.ini" >> /opt/cmdlab/secret/leaks
    else echo "# password=  (vault 에서 주입)"; echo "password_ref=vault://$s/db"; fi
  } > "$C/$s.ini"
done
echo "http 로 시작하는 주소 메모" > "$C/README.txt"
give "$C"
rm -rf /opt/cmdlab/secret/expected && cp -r "$C" /opt/cmdlab/secret/expected
sed -i 's#http://#https://#g' /opt/cmdlab/secret/expected/*.ini
