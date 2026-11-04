# 설명: 모든 컨테이너를 다시 만들면 멀쩡한 web·api·worker 까지 바뀐다
# 실패해야: 다른 컨테이너(web, api, worker)는 그대로
# 모범 풀이 먼저
for c in web api worker; do img=$(docker inspect -f '{{.Config.Image}}' $c); docker rm -f $c > /dev/null; docker run -d --name $c "$img" > /dev/null; done
