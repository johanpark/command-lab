# 설명: PATH 만 고치고 작업 폴더(cd)를 안 고치면 다른 곳에서 실행할 때 상대 경로가 깨진다
# 실패해야: / 에서 cron 같은 환경
sed -i 's|^set -e$|set -e\nexport PATH="$HOME/.local/bin:$PATH"|' ~/deploy/nightly.sh
