#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
token=$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')
secret_set token "$token"
cat > "$H/deploy.sh" <<SCRIPT
#!/usr/bin/env bash
echo "🚀 배포를 시작합니다..."
sleep 1
echo "✅ 배포 완료: \$(date '+%F %T')"
echo "deployed $token" > "\$HOME/deploy-result.txt"
SCRIPT
chmod 644 "$H/deploy.sh"
mkdir -p "$H/secrets"
echo "sk_live_$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')" > "$H/secrets/api.key"
echo "staging-only" > "$H/secrets/README"
chmod 755 "$H/secrets"; chmod 644 "$H/secrets/api.key" "$H/secrets/README"
give "$H/deploy.sh" "$H/secrets"
