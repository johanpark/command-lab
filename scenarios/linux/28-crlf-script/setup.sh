#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
D="$H/deploy"; mkdir -p "$D/lib" "$D/release"
ver="3.$(rand_int 0 9).$(rand_int 0 20)"
secret_set ver "$ver"
echo "<h1>shop $ver</h1>" > "$D/release/index.html"
cat > "$D/deploy.sh" <<'SH'
#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
source ./lib/common.sh
log "배포 시작"
mkdir -p ~/site
cp release/index.html ~/site/
./lib/stamp.sh
log "배포 완료: $(cat ~/site/version.txt)"
SH
cat > "$D/lib/common.sh" <<'SH'
# 공통 함수
log() {
  echo "[$(date +%T)] $*"
}
SH
cat > "$D/lib/stamp.sh" <<SH
#!/usr/bin/env bash
echo "$ver" > ~/site/version.txt
SH
printf '#!/usr/bin/env bash\necho "상태: 정상"\n' > "$D/status.sh"
# Windows 에서 편집된 파일들 (CRLF)
for f in deploy.sh lib/common.sh lib/stamp.sh; do sed -i 's/$/\r/' "$D/$f"; done
chmod 755 "$D/deploy.sh" "$D/status.sh" "$D/lib/stamp.sh"
give "$D"
