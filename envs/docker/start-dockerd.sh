#!/bin/sh
# 실습 컨테이너 안에서 dockerd 를 띄운다 (Docker-in-Docker).
#
# cgroup v2 (Docker Desktop, 최신 리눅스, GitHub Actions) 에서는 프로세스가 들어 있는 cgroup 의
# 하위에 자원 제한을 걸 수 없어서, 안쪽 컨테이너에 --memory 등을 주면 runc 가 실패한다.
# 그래서 지금 프로세스들을 init 하위 cgroup 으로 옮기고, 컨트롤러를 하위 cgroup 에 열어 준다.
# (moby 의 hack/dind 스크립트와 같은 방법)
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
  mkdir -p /sys/fs/cgroup/init
  # 한 번에 하나씩 옮겨야 한다. 그사이 끝난 프로세스(xargs 가 띄운 echo 등) 오류는 무시
  xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs 2>/dev/null || :
  sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers > /sys/fs/cgroup/cgroup.subtree_control || :
fi
dockerd > /var/log/dockerd.log 2>&1 &
exec sleep infinity
