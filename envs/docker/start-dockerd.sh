#!/bin/sh
# 실습 컨테이너 안에서 dockerd 를 띄운다 (Docker-in-Docker).
#
# cgroup v2 (Docker Desktop, 최신 리눅스, GitHub Actions) 에서는 프로세스가 들어 있는 cgroup 의
# 하위에 자원 제한을 걸 수 없어서, 안쪽 컨테이너에 --memory 등을 주면 runc 가 실패한다.
# 그래서 지금 프로세스들을 init 하위 cgroup 으로 옮기고, 컨트롤러를 하위 cgroup 에 열어 준다.
# (moby 의 hack/dind 스크립트와 같은 방법)
#
# 컨테이너가 막 뜬 순간에는 실습 엔진의 docker exec 프로세스가 계속 들어와서,
# 컨트롤러를 여는 쓰기가 EBUSY 로 실패할 수 있다. 성공할 때까지 옮기고 다시 시도한다.
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
  mkdir -p /sys/fs/cgroup/init
  ok=0
  for i in $(seq 1 100); do
    # 한 번에 하나씩 옮겨야 한다. 그사이 끝난 프로세스 오류는 무시
    xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs 2>/dev/null || :
    if sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null; then
      ok=1; break
    fi
    sleep 0.1
  done
  [ "$ok" = 1 ] || echo "start-dockerd: cgroup 컨트롤러를 열지 못했어요. --memory 같은 자원 제한이 동작하지 않을 수 있어요." >> /var/log/dockerd.log
fi
dockerd >> /var/log/dockerd.log 2>&1 &
exec sleep infinity
