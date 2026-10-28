# 해설

```bash
tar tzf ~/downloads/app-2.4.0.tar.gz | head      # app-2.4.0/... 한 겹 더
tar tzf ~/downloads/plugins.tar.gz | head        # 폴더 없이 바로 파일 (타르 폭탄)

mkdir -p /srv/app/releases/2.4.0/plugins
tar xzf ~/downloads/app-2.4.0.tar.gz -C /srv/app/releases/2.4.0 --strip-components=1
tar xzf ~/downloads/plugins.tar.gz   -C /srv/app/releases/2.4.0/plugins
ls -l /srv/app/releases/2.4.0/bin
```

## 풀기 전에 tar t
| 목록 모양 | 그냥 풀면 | 해결 |
|---|---|---|
| `app-2.4.0/bin/start.sh` | `./app-2.4.0/` 폴더가 생김 | `-C 목적지 --strip-components=1` |
| `bin/start.sh` (폴더 없음) | **지금 폴더에 쏟아짐** | `-C 목적지` |
| `/etc/passwd` (절대 경로) | GNU tar 는 앞의 `/` 를 떼고 풀어 줌 | 그래도 출처가 의심스러우면 풀지 말 것 |
| `../../.bashrc` | 위 폴더를 덮어쓸 수 있음 | 믿을 수 없는 압축은 `tar t` 로 반드시 확인 |

## 옵션 기억법
`tar` 의 `x`(extract) `c`(create) `t`(list) + `z`(gzip) + `f`(file). `-C` 는 "change directory" — 풀기 **전에** 그 폴더로 이동한 것처럼 동작해요.

## 다른 압축 형식
| 형식 | 목록 / 풀기 |
|---|---|
| `.tar.gz`, `.tgz` | `tar tzf` / `tar xzf` |
| `.tar.xz` | `tar tJf` / `tar xJf` (요즘 tar 는 `tar xf` 만 해도 알아서) |
| `.zip` | `unzip -l` / `unzip 파일 -d 폴더` |

배포에서는 이렇게 버전 폴더에 풀어 둔 뒤 `ln -sfn releases/2.4.0 current` 로 한 번에 전환해요. (Linux 의 롤백 시나리오 참고)
