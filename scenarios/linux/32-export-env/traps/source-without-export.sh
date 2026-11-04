# 설명: source 만 하고 export 하지 않으면 자식 프로세스(run.sh)에 전달되지 않아 앱이 뜨지 않는다
# 실패해야: 앱이 시작됐다
. ~/app/.env
export APP_ENV=production LOG_LEVEL=warn
~/app/run.sh
