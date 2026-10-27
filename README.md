# command-lab

**상황 속에서 CLI 명령어를 익히는 실습장.**
"디스크가 꽉 찼다", "비밀번호를 커밋해 버렸다" 같은 문제 상황이 담긴 **진짜 리눅스 컨테이너**를 띄우고, 직접 명령어를 입력해 해결하면 자동으로 채점합니다.

- **진짜 환경**: 흉내 낸 셸이 아니라 Docker 컨테이너 안의 실제 bash, git, PowerShell
- **결과로 채점**: 어떤 명령어를 썼는지가 아니라 최종 상태를 검사하므로, 정답 명령어가 하나가 아니에요
- **매번 다른 문제**: 파일명, 숫자, IP 등이 무작위라 답을 외울 수 없어요
- **복습 일정**: 통과한 문제는 1일 → 3일 → 7일 → 14일… 간격으로 다시 추천
- **터미널과 웹 둘 다**: `lab` CLI 또는 브라우저 UI(`lab web`)
- **확장 가능**: 폴더 하나 추가로 새 CLI 환경(kubectl, SQL, …)이나 새 시나리오 추가

## 설치

필요한 것: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (실행 중이어야 함), [Node.js](https://nodejs.org/) 20 이상

```bash
git clone https://github.com/johanpark/command-lab.git
cd command-lab
npm install
npm link            # 'lab' 명령을 어디서나 쓸 수 있게 (선택)
```

`npm link` 를 하지 않았다면 `lab` 대신 `node bin/lab.js` 로 실행하세요.

> **Windows**: PowerShell 또는 Windows Terminal에서 그대로 동작합니다. Docker Desktop은 WSL2 백엔드를 권장합니다.
> **Mac (Apple Silicon)**: 모든 환경 이미지가 arm64를 지원합니다.

첫 실행 때 환경 이미지를 빌드하느라 몇 분 걸립니다. 미리 해 두려면 `lab build`.

## 사용법

### 터미널에서

```bash
lab list                  # 시나리오 목록과 내 진행 상황
lab start linux/01        # 시작: 문제 설명 → 실습 셸 접속
```

실습 셸 안에서 쓸 수 있는 명령:

| 명령 | 하는 일 |
|---|---|
| `task` | 문제 다시 보기 |
| `hint` | 다음 힌트 (`hint 2`, `hint all`) |
| `check` | 지금 상태 채점 |
| `exit` | 셸에서 나가기 → **자동 채점 후 기록 저장** |

그 밖의 명령:

```bash
lab shell                 # 실습 셸에 다시 들어가기
lab check                 # 채점 + 기록
lab reset                 # 문제를 처음 상태로
lab solution              # 해설 (통과 후 권장)
lab stop                  # 실습 종료 (lab stop --all)
lab status                # 환경별 진행률, 복습할 문제
lab review                # 지금 복습할 문제 추천
```

시나리오 ID는 앞부분만 써도 됩니다(`lab start git/02`).

### 브라우저에서

```bash
lab web --open            # http://localhost:4000
```

왼쪽에서 시나리오를 고르고 **▶ 시작**을 누르면 오른쪽에 터미널이 열립니다. 문제, 힌트, 채점 결과, 해설, 내가 입력한 명령어가 한 화면에 보입니다. CLI와 웹은 같은 실습 컨테이너와 같은 기록을 공유해서, 섞어 써도 됩니다.

## 지금 있는 시나리오

| 환경 | 시나리오 |
|---|---|
| **Linux (bash)** | 처음 접속한 서버에서 메모 찾기 · 숨겨진 설정 파일 · 블로그 작업 폴더 만들기 · 다운로드 폴더 대청소 · 에러 로그 살펴보기 · 수상한 접속 IP 찾기 · Permission denied 해결하기 · CPU를 잡아먹는 프로세스 · 디스크가 꽉 찼어요 · 어제 누가 설정을 바꿨지?(find) · 설정 파일 일괄 수정하기(sed) · 포트가 이미 사용 중입니다 · 백업에서 파일 하나만 살리기(tar) · 정해진 시간에 자동으로 실행하기(cron) · command not found(PATH) |
| **Git** | 첫 커밋 만들기 · 비밀번호를 커밋해 버렸다 · 머지 충돌 해결하기 · 망가뜨린 파일 되살리기 · 작업 중에 긴급 버그 수정(stash) |
| **PowerShell** | PowerShell 첫걸음 · 객체 파이프라인으로 매출 분석 · 오래된 로그 정리하기 |

`ls`, `cd` 정도만 아는 상태라면 `linux/01`부터 순서대로 진행하세요.

## 구조

```
command-lab/
├── bin/lab.js            CLI
├── src/
│   ├── catalog.js        envs/, scenarios/ 폴더를 읽어 카탈로그 구성
│   ├── docker.js         이미지 빌드, 컨테이너 생성, 명령 실행, 웹 터미널 연결
│   ├── session.js        시작 → 채점 → 종료 (CLI와 웹이 공유)
│   ├── progress.js       기록과 복습 일정 (~/.cmdlab/progress.json)
│   └── server.js         웹 UI 서버 (REST + WebSocket 터미널)
├── web/                  브라우저 UI (xterm.js)
├── lib/                  컨테이너 안으로 복사되는 공통 도구 (task/hint/check, 채점 헬퍼)
├── envs/<환경>/          환경 = 연습할 CLI 종류 (Dockerfile + env.yaml)
└── scenarios/<환경>/<시나리오>/   문제 상황 하나
```

```
lab start ──▶ 환경 이미지 확인/빌드 ──▶ 컨테이너 생성 ──▶ lib/·시나리오 복사
          ──▶ setup.sh (root: 문제 상황 만들기, 정답은 숨김 폴더에)
          ──▶ 학습자 셸 (learner 계정)
lab check ──▶ check.sh (root: 결과 상태 검사, ✔/✘ 출력, 종료코드로 통과 판정)
          ──▶ 입력한 명령어 기록 수집 ──▶ ~/.cmdlab/progress.json
```

## 확장하기

새 시나리오나 새 CLI 환경을 추가하는 방법은 [docs/AUTHORING.md](docs/AUTHORING.md)를 보세요. 요약하면:

- **새 시나리오**: `scenarios/<환경>/<번호-이름>/` 폴더에 `scenario.yaml`, `task.md`, `setup.sh`, `check.sh`(+ `hints.md`, `debrief.md`, `solution.sh`)
- **새 환경**: `envs/<이름>/` 폴더에 `Dockerfile`, `env.yaml`
- **검증**: `lab validate` (구조 검사), `lab test <시나리오>` (풀기 전엔 실패, 모범 풀이 후엔 통과하는지 자동 확인)

## 문제 해결

- **"Docker에 연결할 수 없습니다"**: Docker Desktop이 실행 중인지 확인하세요. 다른 런타임(colima, OrbStack 등)은 `DOCKER_HOST` 환경변수로 지정할 수 있습니다.
- **이미지 빌드가 실패해요**: 네트워크 문제일 수 있습니다. `lab build <환경> --no-cache` 로 다시 시도하세요.
- **실습 컨테이너 정리**: `lab stop --all`. 이미지까지 지우려면 `docker image rm cmdlab-env-linux cmdlab-env-git cmdlab-env-powershell`.
- **기록 초기화**: `~/.cmdlab/progress.json` 삭제. 기록 위치는 `CMDLAB_HOME` 환경변수로 바꿀 수 있습니다.
