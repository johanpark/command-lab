# 설명: --strip-components 를 빼면 app-2.4.0/ 폴더가 한 겹 더 생긴다
# 실패해야: 한 겹 더 들어갔어요
mkdir -p /srv/app/releases/2.4.0/plugins
tar xzf ~/downloads/app-2.4.0.tar.gz -C /srv/app/releases/2.4.0
tar xzf ~/downloads/plugins.tar.gz -C /srv/app/releases/2.4.0/plugins
