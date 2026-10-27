`docker stats --no-stream` 을 보세요. **MEM % 가 아니라 MEM USAGE** 열을 비교해야 해요. MEM % 는 *각 컨테이너의 상한 대비* 비율이라, 상한이 작은 컨테이너는 조금만 써도 % 가 커 보여요. LIMIT 열이 서버 전체 메모리와 같다면 상한이 없다는 뜻이에요.
---
다시 만들기 전에 원래 설정을 확인하세요: `docker inspect -f '{{.Config.Image}} {{.HostConfig.RestartPolicy.Name}}' 이름`
---
`docker rm -f 이름` → `docker run -d --name 이름 --memory 256m --restart unless-stopped 이미지`

(실행 중인 컨테이너에 바로 거는 `docker update --memory 256m --memory-swap 256m 이름` 도 있어요. 하지만 `docker run` 명령을 기록해 두지 않으면 다음에 다시 만들 때 상한이 사라지니, 실무에서는 compose 파일이나 실행 스크립트에도 꼭 반영하세요.)
---
`docker stats --no-stream` 에서 그 컨테이너의 LIMIT 이 `256MiB` 로 바뀌었는지, `docker ps` 에서 Up 인지 확인!
