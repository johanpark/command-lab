# 설명: PATH=~/tools/bin 으로 덮어쓰면 ls·grep 까지 못 찾는다
# 실패해야: ls, grep 도 잘 동작한다
echo 'export PATH="$HOME/tools/bin"' >> ~/.bashrc
~/tools/bin/deploytool --version > ~/answer.txt
