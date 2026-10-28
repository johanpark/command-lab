# 릴리스 압축 파일 제자리에 풀기

새 버전 **2.4.0** 배포 준비 중이에요. 빌드 서버에서 받은 파일 두 개가 `~/downloads` 에 있어요.

| 파일 | 내용 |
|---|---|
| `app-2.4.0.tar.gz` | 앱 본체 |
| `plugins.tar.gz` | 플러그인 모음 |

서버의 릴리스는 이렇게 놓여 있어야 해요.
```
/srv/app/releases/2.3.9/      ← 지금 버전 (건드리지 마세요)
/srv/app/releases/2.4.0/      ← 여기에 새 버전
    bin/start.sh
    VERSION
    ...
    plugins/                  ← 플러그인은 여기에
        ...
```

## 목표
1. `app-2.4.0.tar.gz` 를 **`/srv/app/releases/2.4.0/`** 에 풀어서 `/srv/app/releases/2.4.0/bin/start.sh` 가 되게 하세요. (`2.4.0/app-2.4.0/bin/...` 처럼 한 겹 더 들어가면 안 돼요)
2. `plugins.tar.gz` 를 **`/srv/app/releases/2.4.0/plugins/`** 에 푸세요.
3. 홈 폴더나 `~/downloads` 에 압축이 잘못 풀린 **찌꺼기가 없어야** 해요.
4. 실행 파일의 **실행 권한**이 유지돼야 하고, 2.3.9 는 그대로여야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `tar tzf 파일.tar.gz` | 풀지 않고 **목록만** 보기 (먼저 꼭!) |
| `tar tzf 파일 \| head` | 맨 위 몇 줄만 |
| `tar xzf 파일 -C 폴더` | 그 폴더 **안에** 풀기 (폴더는 미리 있어야 함) |
| `tar xzf 파일 -C 폴더 --strip-components=1` | 경로 맨 앞 한 단계(`app-2.4.0/`)를 떼고 풀기 |
| `mkdir -p 폴더` | 폴더 만들기 |
