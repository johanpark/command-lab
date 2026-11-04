# 설명: ln -sf 만 쓰면 current 가 폴더를 가리키는 링크라 그 안에 새 링크가 생긴다
# 실패해야: 2.4.0 폴더는 그대로
# 실패해야: releases/2.3.1 을 가리킨다
cd ~/app
ln -sf releases/2.3.1 current
./restart.sh
diff -r releases/2.3.1 releases/2.4.0 | grep '^Only in releases/2.3.1' | awk '{print $NF}' > ~/answer.txt
