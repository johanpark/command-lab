# 해설

```bash
docker images                                  # shop-web 1.0
docker ps -a                                   # old-web: Exited
docker run -d --name web -p 8080:80 shop-web:1.0
docker ps                                      # web: Up, 0.0.0.0:8080->80/tcp
curl http://localhost:8080
docker logs web                                # 방금 curl 한 요청이 찍혀 있어요
docker rm old-web
```

## docker run 옵션 정리
| 옵션 | 뜻 |
|---|---|
| `-d` | 백그라운드 실행 (없으면 터미널이 컨테이너에 붙잡힘) |
| `--name web` | 이름 (없으면 `angry_turing` 같은 무작위 이름) |
| `-p 8080:80` | **내 서버 8080 → 컨테이너 80**. 순서 헷갈리지 않기: "바깥:안" |
| `-e KEY=값` | 환경 변수 |
| `-v 볼륨:/경로` | 데이터 저장 공간 연결 |
| `--rm` | 멈추면 자동 삭제 (일회용 실행에 좋음) |
| `-it` | 대화형 셸 (`docker run -it busybox sh`) |

## 자주 쓰는 확인 명령
```bash
docker logs -f web          # 로그 실시간
docker exec -it web sh      # 실행 중인 컨테이너 안으로 들어가기
docker inspect web          # 모든 설정 (JSON)
docker stats                # 컨테이너별 CPU/메모리 (top 같은 것)
```

> 이 실습 환경은 인터넷이 없어도 되도록 `busybox` 이미지를 미리 만들어 뒀어요. 실제로는 `docker pull nginx` 처럼 Docker Hub 에서 받아 씁니다.
