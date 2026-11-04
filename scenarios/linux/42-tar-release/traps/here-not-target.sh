# 설명: -C 를 빼면 지금 폴더(홈)에 풀려 찌꺼기가 남는다
# 실패해야: plugins/ 에 있다
# 실패해야: 엉뚱한 곳에 풀린 찌꺼기
mkdir -p /srv/app/releases/2.4.0
tar xzf ~/downloads/app-2.4.0.tar.gz -C /srv/app/releases/2.4.0 --strip-components=1
cd ~ && tar xzf ~/downloads/plugins.tar.gz
