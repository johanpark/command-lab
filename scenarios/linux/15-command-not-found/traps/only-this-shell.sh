# 설명: export 만 하고 ~/.bashrc 에 저장하지 않으면 새 터미널에선 다시 안 된다
# 실패해야: 새 터미널에서도 deploytool
export PATH="$PATH:$HOME/tools/bin"
deploytool --version > ~/answer.txt
