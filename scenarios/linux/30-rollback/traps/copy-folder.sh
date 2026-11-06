# 설명: 링크 대신 폴더를 복사하면 current 가 심볼릭 링크가 아니다
# 실패해야: 심볼릭 링크다
cd ~/app
rm current
cp -r releases/2.3.1 current
./restart.sh
diff -r releases/2.3.1 releases/2.4.0 | grep '^Only in releases/2.3.1' | awk '{print $NF}' > ~/answer.txt
