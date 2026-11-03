# shellcheck shell=bash
# docker 환경 시나리오의 setup.sh 에서 helpers.sh 다음에 source 한다.

# 컨테이너 안의 dockerd 가 준비될 때까지 기다린다
wait_docker() {
  local i
  for i in $(seq 1 60); do
    docker info >/dev/null 2>&1 && return 0
    sleep 0.5
  done
  echo "dockerd 가 시작되지 않았어요:" >&2
  tail -n 20 /var/log/dockerd.log >&2
  return 1
}

# 인터넷 없이 쓸 수 있는 busybox:latest 이미지를 busybox-static 으로 만든다
ensure_busybox() {
  docker image inspect busybox:latest >/dev/null 2>&1 && return 0
  local r a
  r=$(mktemp -d)
  chmod 755 "$r" # mktemp 는 700 이라 그대로 넣으면 이미지의 / 가 700 이 돼서 root 가 아닌 사용자는 아무것도 못 연다
  mkdir -p "$r/bin" "$r/etc" "$r/tmp" "$r/root"
  cp "$(command -v busybox)" "$r/bin/busybox"
  for a in $("$r/bin/busybox" --list); do [ "$a" = busybox ] || ln -s busybox "$r/bin/$a"; done
  echo 'root:x:0:0:root:/root:/bin/sh' > "$r/etc/passwd"
  echo 'root:x:0:' > "$r/etc/group"
  echo '127.0.0.1 localhost' > "$r/etc/hosts"
  chmod 1777 "$r/tmp"
  tar -C "$r" -c . | docker import -c 'CMD ["sh"]' -c 'ENV PATH=/bin' - busybox:latest >/dev/null
  rm -rf "$r"
}

# build_image 태그 [폴더] < Dockerfile 내용
# 폴더를 주면 그 안의 파일을 빌드 컨텍스트로 쓴다
build_image() {
  local tag=$1 dir=${2:-}
  [ -n "$dir" ] || dir=$(mktemp -d)
  cat > "$dir/Dockerfile"
  docker build -q -t "$tag" "$dir" >/dev/null
}
