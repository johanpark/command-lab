#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/build" "$H/www" "$H/releases"
for v in 2.4.3 2.5.0; do
  t=$(mktemp -d); echo "$v" > "$t/version.txt"; echo "<h1>shop $v</h1>" > "$t/index.html"
  tar -czf "$H/build/app-v$v.tar.gz" -C "$t" . ; rm -rf "$t"
done
echo 2.4.3 > "$H/www/version.txt"; echo "<h1>shop 2.4.3</h1>" > "$H/www/index.html"
cat > "$H/deploy.sh" <<'SH'
#!/usr/bin/env bash
# 사용법: deploy.sh <버전>
VERSION=$1
ARTIFACT=~/build/app-$VERSION.tar.gz

echo "▶ 빌드 산출물 확인: $ARTIFACT"
ls -l "$ARTIFACT"

echo "▶ 압축 풀기"
mkdir -p ~/releases/$VERSION
tar -xzf "$ARTIFACT" -C ~/releases/$VERSION

echo "▶ 현재 버전 교체"
cp -r ~/releases/$VERSION/* ~/www/

echo "✅ 배포 성공! ($VERSION)"
SH
chmod 755 "$H/deploy.sh"
give "$H/build" "$H/www" "$H/releases" "$H/deploy.sh"
