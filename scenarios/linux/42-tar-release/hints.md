풀기 전에 항상 목록부터: `tar tzf ~/downloads/app-2.4.0.tar.gz | head` 와 `tar tzf ~/downloads/plugins.tar.gz | head`. 하나는 모든 경로가 `app-2.4.0/` 로 시작하고, 다른 하나는 **폴더 없이** 파일이 바로 나와요.
---
`plugins.tar.gz` 처럼 맨 위 폴더가 없는 압축을 아무 데서나 `tar xzf` 하면 **지금 폴더에 파일이 쏟아져요.** (이런 걸 "타르 폭탄"이라고 불러요) 그래서 `-C 폴더` 로 풀 곳을 꼭 정하세요. 폴더는 `mkdir -p` 로 먼저 만들어야 해요.
---
앱: `mkdir -p /srv/app/releases/2.4.0` → `tar xzf ~/downloads/app-2.4.0.tar.gz -C /srv/app/releases/2.4.0 --strip-components=1`
---
플러그인: `mkdir -p /srv/app/releases/2.4.0/plugins` → `tar xzf ~/downloads/plugins.tar.gz -C /srv/app/releases/2.4.0/plugins`. 이미 홈에 잘못 풀었다면 `tar tzf ~/downloads/plugins.tar.gz` 목록을 보고 그 파일들만 지우세요. 확인: `ls -l /srv/app/releases/2.4.0/bin/`
