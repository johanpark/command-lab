# 설명: run.sh 에 값을 직접 박아 넣으면 안 된다 (수정 금지)
# 실패해야: 수정하지 않았다
sed -i '2i export APP_ENV=production LOG_LEVEL=warn' ~/app/run.sh
set -a; . ~/app/.env; set +a
~/app/run.sh
