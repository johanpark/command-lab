set -a; source ~/app/.env; set +a
export APP_ENV=production LOG_LEVEL=warn
~/app/run.sh
