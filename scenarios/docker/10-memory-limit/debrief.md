# 해설

```bash
docker stats --no-stream
# NAME           MEM USAGE / LIMIT
# report-cache   58MiB / 1.5GiB      ← 상한 없음 (서버 전체가 한도)
# web            1MiB / 128MiB
docker inspect -f '{{.Config.Image}} {{.HostConfig.RestartPolicy.Name}}' report-cache
docker rm -f report-cache
docker run -d --name report-cache --memory 256m --restart unless-stopped report-cache:2.1
docker stats --no-stream                # 58MiB / 256MiB
```

## 왜 상한이 중요할까?
상한이 없는 컨테이너가 메모리를 계속 먹으면, 리눅스는 결국 **서버 전체에서** 프로세스를 강제로 죽여요(OOM Killer). 엉뚱하게 DB 가 죽을 수도 있어요. 상한을 걸면 **그 컨테이너만** 한도에서 멈추거나 재시작돼요.

## 자원 제한 옵션
| 옵션 | 뜻 |
|---|---|
| `--memory 256m` | 메모리 상한 (넘으면 컨테이너 안에서 OOM) |
| `--memory-reservation 128m` | 평소 보장량 (부족할 때 이만큼은 우선) |
| `--cpus 0.5` | CPU 코어 0.5개분까지 |
| `--pids-limit 100` | 프로세스 수 상한 (fork 폭탄 방지) |

## 다시 만들지 않고 바꾸기
```bash
docker update --memory 256m --memory-swap 256m report-cache
```
실행 중인 컨테이너의 자원 제한은 `docker update` 로 바꿀 수 있어요. 다만 이미지·환경 변수·포트는 다시 만들어야 해요.

## Compose 에서는
```yaml
services:
  report-cache:
    image: report-cache:2.1
    mem_limit: 256m
```
