# command-lab

**상황 속에서 CLI 명령어를 익히는 실습장.**
"디스크가 꽉 찼다", "비밀번호를 커밋해 버렸다" 같은 문제 상황이 담긴 **진짜 리눅스 컨테이너**를 띄우고, 직접 명령어를 입력해 해결하면 자동으로 채점합니다.

- **진짜 환경**: 흉내 낸 셸이 아니라 Docker 컨테이너 안의 실제 bash, git, Docker, PowerShell, sqlite3, Python·Node.js, AWS CLI
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

## 지금 있는 시나리오 (126개)

각 환경 안에서 카테고리별로 묶여 있어요. 웹 화면 왼쪽 목록과 `lab list` 가 같은 순서로 보여줍니다.

| 환경 | 카테고리 | 시나리오 |
|---|---|---|
| 🐧 **Linux (bash)** | 📁 파일과 폴더 | 처음 접속한 서버에서 메모 찾기 · 숨겨진 설정 파일 · 블로그 작업 폴더 만들기 · 다운로드 폴더 대청소 · vim 만 있는 서버 |
| | 📝 텍스트·로그 처리 | 에러 로그 살펴보기 · 수상한 접속 IP 찾기 · 설정 파일 일괄 수정하기(sed) · 매출 리포트 만들기(awk) · 두 파일 비교하기(diff, comm) · 압축된 옛 로그에서 찾기(zgrep) · 몇 시 몇 분에 장애가 났지?(시간대별 집계) |
| | 💾 검색·압축·백업 | 어제 누가 설정을 바꿨지?(find) · 백업에서 파일 하나만 살리기(tar) · rsync 로 백업 동기화 · 깨진 심볼릭 링크 정리하기 · 릴리스 압축 파일 제자리에 풀기(tar -C, --strip-components) |
| | 🔐 권한과 사용자 | Permission denied 해결하기 · 팀 공유 폴더 만들기(사용자·그룹) · 특정 명령만 sudo 허용하기(sudoers) · sudo 를 붙였는데도 Permission denied(tee) · 신입 서버 계정 만들기(useradd, usermod -aG) · chmod -R 777 을 되돌려라 |
| | 🧰 셸과 자동화 | command not found(PATH) · 사진 파일 이름 한꺼번에 바꾸기(for) · 정해진 시간에 자동으로 실행하기(cron) · 첫 셸 스크립트 만들기 · 앱이 환경 변수를 못 읽어요(export) · 이름에 공백이 있는 파일 한꺼번에 처리하기(xargs -0) · 터미널을 닫아도 작업이 계속 돌게(nohup) |
| | 🌐 네트워크·원격 접속 | API 서버 상태 점검(curl, jq) · SSH 키로 접속 준비하기 · 엉뚱한 서버로 접속해요(/etc/hosts) · ssh 접속 별칭 만들기(~/.ssh/config) |
| | 🚀 배포 스크립트 | 배포가 실패했어요(로그) · 윈도우에서 고친 배포 스크립트(CRLF) · 실패했는데 "배포 성공"이래요(set -e) · 새 버전이 망가졌어요, 롤백!(ln -sfn) · 손으로는 되는데 cron 에선 실패해요 |
| | ☁️ AWS 서버(EC2) | .pem 키로 EC2 서버 접속하기(ec2-user, chmod 400) · 새 EC2 에서 앱이 안 떠요(user-data, cloud-init 로그) |
| | 🚨 장애 대응 | CPU를 잡아먹는 프로세스 · 디스크가 꽉 찼어요 · 포트가 이미 사용 중입니다 · CPU가 튀는 원인 찾기(top) · 지웠는데 디스크가 안 비어요(lsof) |
| 🐍 **Python · Node.js** | 📂 파일 자동 처리 | 파일 정리 파이썬 스크립트 고치기 · pip install 이 막혀요(가상환경 venv) |
| | 📊 엑셀·데이터 처리 | 엑셀 월별 시트 합쳐서 보고서 만들기(openpyxl) · 깨진 JSON 이 섞인 주문 집계(Node.js) · 한글이 깨지는 CSV 합치기(인코딩) · API 결과가 20개뿐이에요(페이지네이션) |
| | ⏰ 스크립트 자동 실행 | 파이썬·노드 스크립트를 cron 에 등록하기 |
| 🌿 **Git** | 🌱 Git 시작하기 | 첫 커밋 만들기 · .gitignore 에 넣었는데 계속 올라가요 |
| | ⏪ 기록과 되돌리기 | 비밀번호를 커밋해 버렸다 · 망가뜨린 파일 되살리기 · 버그를 만든 커밋 찾아 되돌리기 · 40개 커밋 중 범인 찾기(bisect) · reset --hard 로 날린 커밋 되살리기(reflog) · 이 값을 누가 바꿨지?(blame -w, log -S) · 방금 한 커밋 고치기(amend) |
| | 🔀 브랜치와 협업 | 머지 충돌 해결하기 · 작업 중에 긴급 버그 수정(stash) · 지저분한 커밋 정리하기(rebase -i) · push 가 거절됐어요(pull --rebase) · 보안 패치 하나만 옮기기(cherry-pick) · main 에 커밋해 버렸어요(브랜치로 옮기기) · 릴리스에 태그 달기(git tag) |
| 🐳 **Docker** | 📦 컨테이너 기본 | 첫 컨테이너 띄우기 · 컨테이너 속 들여다보기(exec, inspect, cp) |
| | 🏗️ 이미지와 Compose | Dockerfile 직접 써서 배포하기 · docker compose 로 한 번에 띄우기 · 이미지가 왜 이렇게 커요?(.dockerignore) |
| | 🔗 네트워크와 볼륨 | 컨테이너끼리 연결이 안 돼요 · 업그레이드해도 데이터 지키기 · 컨테이너가 폴더에 못 써요(볼륨 권한) |
| | 🚨 장애 대응·정리 | 계속 재시작하는 컨테이너 · Docker 가 디스크를 다 먹었어요 · 배포 스크립트가 두 번째부터 실패해요 · 메모리 먹는 컨테이너 가두기(--memory) · unhealthy 컨테이너 살리기(헬스체크) · port is already allocated |
| ☁️ **AWS (CLI)** | 🧭 AWS CLI 시작하기 | 처음 받은 AWS 계정 둘러보기(--query, --filters) |
| | 🪣 S3 저장소 | S3 에 백업 올리고 웹사이트 동기화하기(sync --delete) · 계속 쌓이는 로그 버킷 정리 규칙(수명 주기) · 덮어쓰고 지워버린 설정 파일 되살리기(버전 관리) · 외부 업체에 파일 하나만 하루 동안 공유하기(미리 서명된 URL) |
| | 🖥️ EC2·네트워크 | 전 세계에 열린 SSH 포트 막기(보안 그룹, IPv6) · 밤에는 개발 서버 끄기(태그, JMESPath) · 붙어 있지 않은 EBS 볼륨 정리(비용 절감) · 프라이빗 서버가 인터넷에 못 나가요(라우팅 테이블, NAT) · 새 서버로 이사하기(Route 53) · 로드 밸런서 뒤 서버를 새 버전으로 교체(ALB 대상 그룹) · NAT 요금 폭탄 줄이기(VPC 게이트웨이 엔드포인트) · 세일 이벤트 대비 서버 늘리고 줄이기(Auto Scaling) |
| | 🛡️ 보안 점검 | 실수로 공개된 S3 버킷 찾아 막기(Block Public Access) · 관리자 권한 가진 봇 계정 줄이기(IAM 최소 권한) · 퇴사자 계정 막기 — 지우지 말고 잠그기(IAM) · 결제 설정 파일 암호화하고 키 관리하기(KMS) |
| | 🗃️ DynamoDB | 고객 문의 처리하기 — 주문 조회와 환불(query, update-item) · 지워진 상품만 백업에서 되살리기(백업 복원, PITR) |
| | 📨 SQS·SNS 메시지 | 처리 못 한 주문 메시지 다시 넣기(데드레터 큐) · 주문 이벤트를 여러 팀에 나눠 보내기(SNS → SQS 팬아웃, 필터) |
| | 🔐 로그·알람·비밀 관리 | 서버에 안 들어가고 로그에서 에러 찾기(CloudWatch Logs) · .env 의 비밀번호를 Secrets Manager 로 옮기기 · Parameter Store 에서 설정 파일 만들기(SSM) · CPU 가 치솟으면 알림 받기(CloudWatch 알람, SNS) · 새벽 배치가 오후에 돌아요(EventBridge, UTC) |
| ⚡ **PowerShell** | 🚀 시작하기 · 🔗 객체 파이프라인 · 🛠️ 관리 작업 | PowerShell 첫걸음 · 객체 파이프라인으로 매출 분석 · 설정 파일 검색·일괄 수정 · 오래된 로그 정리하기 · 프로세스 살펴보고 정리하기 · JSON 설정 파일 고치기(-Depth) · CSV 명단으로 폴더 한꺼번에 만들기 |
| 🗄️ **SQL (sqlite3)** | 🔎 조회하기 · ✏️ 데이터 고치기 | 쇼핑몰 DB 첫 조회 · 테이블 합쳐서 분석하기(JOIN) · 느린 쿼리 빠르게 만들기(인덱스) · 데이터 안전하게 고치기 · 실수로 지운 데이터 복구(ATTACH) · 중복 가입 정리하기(GROUP BY, UNIQUE) · 월별 매출 보고서 CSV 로 내보내기 · WHERE 없는 UPDATE 사고 복구 · NULL 때문에 숫자가 이상해요 · 월말 매출이 사라졌어요(날짜 범위) |

`ls`, `cd` 정도만 아는 상태라면 Linux 의 📁 파일과 폴더부터 순서대로 진행하세요. 🚨 장애 대응은 앞의 카테고리를 어느 정도 익힌 뒤 도전하는 실전 문제예요.

### AWS 환경에 대해

- 실습 컨테이너 안에서 **가짜 AWS**([moto](https://github.com/getmoto/moto))가 돌아가고, 진짜 **AWS CLI** 가 거기에 연결돼 있어요. 명령은 실제 AWS 와 똑같지만 계정·인터넷·요금이 필요 없고, 무엇을 지워도 괜찮아요.
- 흉내라서 EC2 에 실제로 SSH 접속하거나 웹 콘솔을 쓸 수는 없고, IAM 권한 거부(AccessDenied)는 진짜처럼 막히지 않아요. EC2 서버 *안*에서 하는 일은 Linux 환경의 ☁️ AWS 서버(EC2) 카테고리에서 연습하세요.

### Docker 환경에 대해

- 실습 컨테이너 **안에서 별도의 Docker 엔진**이 돌아가요(Docker-in-Docker). 실습 중에 만들고 지우는 컨테이너·이미지·볼륨은 **내 PC 의 Docker 와 완전히 분리**돼 있어서 마음껏 지워도 됩니다.
- 이를 위해 Docker 환경의 실습 컨테이너만 **privileged 모드**로 실행해요. 내 PC 에서만 쓰는 연습용이라 괜찮지만, 공용 서버에 띄워 여러 사람이 쓰는 용도로는 쓰지 마세요.
- 인터넷 없이도 되도록 `busybox` 이미지를 컨테이너 안에서 직접 만들어 둡니다. 그래서 `docker pull` 로 Docker Hub 이미지를 받는 대신, 준비된 이미지(`shop-web:1.0` 등)와 `busybox` 를 씁니다.

## 웹 화면 사용 팁

- **홈**: "이어서 하기" 카드가 하던 문제(없으면 복습할 문제, 다음 추천 문제)를 보여줘요. 카테고리를 누르면 그 카테고리에서 안 푼 첫 문제로 갑니다.
- **왼쪽 목록**: 위쪽 탭으로 환경(Linux/Script/Git/Docker/AWS/pwsh/SQL)을 고르고, 카테고리를 눌러 펼치고 접어요. 점(●○)은 카테고리 안 문제들의 상태예요. `남은 문제만` 을 켜면 통과한 문제를 숨겨요. 검색(`/` 키)은 모든 환경에서 찾아줘요.
- **실습 화면**: 문제·힌트·해설·기록 탭 / 가운데 경계를 드래그해서 크기 조절 / `⇤` 로 문제 패널 접기 / `A−` `A+` 터미널 글자 크기
- **단축키**: `Ctrl`+`Enter` 채점 (터미널 안에서도), `Alt`+`←` `→` 이전·다음 문제, `?` 도움말
- **터미널 복사·붙여넣기**: 글자를 드래그해서 고르고 `Ctrl`+`C`, 붙여넣기는 `Ctrl`+`V` (맥은 `⌘`). 고른 글자가 없으면 `Ctrl`+`C` 는 원래대로 실행 중인 명령을 멈춰요(`^C`).
- 오른쪽 위 버튼으로 라이트/다크 테마를 바꿀 수 있어요.

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
- **실습 컨테이너 정리**: `lab stop --all`. 이미지까지 지우려면 `docker image rm cmdlab-env-linux cmdlab-env-git cmdlab-env-docker cmdlab-env-powershell cmdlab-env-sql`.
- **기록 초기화**: `~/.cmdlab/progress.json` 삭제. 기록 위치는 `CMDLAB_HOME` 환경변수로 바꿀 수 있습니다.
