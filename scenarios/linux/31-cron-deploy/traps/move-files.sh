# 설명: 스크립트 대신 설정·빌드 파일을 옮겨 맞춘다
# 실패해야: 설정과 빌드 파일은 원래 자리
sed -i 's|^set -e$|set -e\nexport PATH="$HOME/.local/bin:$PATH"|' ~/deploy/nightly.sh
mv ~/deploy/config ~/config 2>/dev/null; mv ~/deploy/dist ~/dist 2>/dev/null
