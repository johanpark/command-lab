# 시나리오와 환경 만들기

command-lab은 두 가지 단위로 확장합니다.

- **환경(env)**: "어떤 CLI를 연습하는가". Docker 이미지 하나. 예: `linux`, `git`, `powershell`
- **시나리오(scenario)**: "어떤 상황을 해결하는가". 환경 위에서 돌아가는 문제 하나

코드 수정 없이 폴더만 추가하면 CLI와 웹에 자동으로 나타납니다.

---

## 1. 시나리오 만들기

```
scenarios/linux/10-my-scenario/
├── scenario.yaml    필수: 메타데이터
├── task.md          필수: 학습자에게 보여줄 문제
├── setup.sh         필수: 문제 상황 만들기 (root로 실행)
├── check.sh         필수: 채점 (root로 실행, 종료코드 0이면 통과)
├── hints.md         선택: 단계별 힌트 (--- 줄로 구분)
├── debrief.md       선택: 통과 후 보여줄 해설
├── solution.sh      선택(강력 권장): 모범 풀이. lab test 가 사용
│                    (PowerShell 환경은 solution.ps1)
└── traps/           선택(강력 권장): 함정·변형 테스트. lab test 가 사용 (컨테이너에는 들어가지 않음)
```

컨테이너 안의 학습자는 `task.md` 와 `hints.md` 만 읽을 수 있어요. 나머지(채점용 `*.py` 같은 보조 파일 포함)는 root 만 읽을 수 있게 숨겨져요.

폴더 이름의 앞 번호가 목록 순서가 됩니다. `_` 나 `.` 으로 시작하는 폴더는 무시됩니다(작업 중인 초안용).

### scenario.yaml

```yaml
title: 디스크가 꽉 찼어요         # 목록에 보일 제목
category: storage                 # env.yaml 의 categories 중 하나의 id
level: 3                          # 난이도 1~3 (입문/기초/실전)
minutes: 20                       # 예상 소요 시간
tags: [du, find, sort]            # 다루는 명령어
summary: 한 줄 설명
# env: linux                      # 생략하면 상위 폴더 이름(scenarios/<env>/...)
```

### task.md 작성 요령

- **상황(스토리)** → **목표(번호 목록)** → **써볼 명령어(표)** 순서를 추천합니다.
- 목표는 **채점 가능한 결과**로 쓰세요. "로그를 분석하세요" 대신 "ERROR 줄 개수를 `~/answer.txt` 에 저장하세요".
- 답을 적어야 하는 문제는 `~/answer.txt` 에 저장하게 하면 리다이렉션(`>`)까지 자연스럽게 연습됩니다.

### setup.sh / check.sh 에서 쓸 수 있는 헬퍼

맨 위에서 `source /opt/cmdlab/lib/helpers.sh` 를 하면 다음을 쓸 수 있습니다. (정의: [`lib/helpers.sh`](../lib/helpers.sh))

| 이름 | 용도 |
|---|---|
| `$H` | 학습자 홈 디렉터리 (`/home/learner`) |
| `$LEARNER` | 학습자 계정 이름 |
| `give 경로...` | 소유자를 학습자로 바꿈 (root로 만든 파일은 꼭 `give`) |
| `as_learner 명령...` | 학습자 권한으로 실행 (git 저장소 만들 때 등) |
| `spawn_bg 명령...` | 학습자 권한으로 백그라운드 프로세스 시작 |
| `rand_int 최소 최대`, `rand_pick a b c` | 무작위 값 |
| `secret_set 이름 값`, `secret_get 이름` | 정답 저장/조회 (`/opt/cmdlab/secret`, 학습자는 못 읽음) |
| `pass "설명"`, `fail "설명"` | 채점 항목 출력 |
| `expect "설명" 명령...` | 명령이 성공하면 pass, 아니면 fail |
| `expect_answer "설명" 기대값 [파일]` | `~/answer.txt`(기본) 내용 비교. 앞뒤 공백/빈 줄/CRLF 무시 |
| `answer [파일]` | 답안 파일 내용 (정리된 값) |
| `expect_cell "설명" 기대값 [파일]` | sqlite3 처럼 표(머리글, 테두리 포함)로 저장된 답안에서 마지막 값 한 칸을 비교 |
| `finish` | 하나라도 fail 이면 종료코드 1 |

#### 공용 채점 도구 (파이썬, [`lib/grading`](../lib/grading))
문자열을 비교하는 대신 **실제 규칙대로 계산**해서 채점하면, 학습자가 다르게 써도 결과가 맞으면 통과하고, 그럴듯하지만 틀린 답은 정확히 걸러져요. `helpers.sh` 를 source 하면 파이썬에서 바로 `import` 할 수 있어요. (학습자에게는 보이지 않음)

| 모듈 | 하는 일 |
|---|---|
| `policy` | IAM 정책·신뢰 정책·SCP 평가. 명시적 Deny > Allow, `*`·`?` 와일드카드, NotAction·NotResource, 조건(String·Arn·Bool·Null·Numeric, IfExists). `allowed(문서들, 작업, 리소스, 조건값)`, `scp_decide(단계별 문서들, ...)`, `assume_principals(신뢰 정책)` |
| `cron` | AWS cron 식을 시간대째 실제로 굴려 보기. `fires(식, tz)` → 한국 시간 목록, `describe(목록)` |

```python
import policy
policy.allowed([doc], 's3:GetObject', 'arn:aws:s3:::reports/2026/a.csv')   # True / False
import cron
cron.fires('cron(0 18 L * ? *)')            # 한국 시간 1월 1일 03:00, 2월 1일 03:00
```
새 기능이 필요하면 모듈에 넣고 [`test_grading.py`](../lib/grading/test_grading.py) 에 테스트를 더하세요 (`python3 -m unittest discover -s lib/grading`, CI 에서도 돌아요).

### 좋은 시나리오의 조건

1. **매번 달라야 합니다.** 정답이 되는 값(숫자, 파일 위치, IP, 프로세스 이름)은 `rand_*` 로 만들고 `secret_set` 으로 숨겨 두세요.
2. **과정이 아니라 결과를 채점합니다.** `find` 로 풀든 `du` 로 풀든 결과가 맞으면 통과해야 합니다.
3. **"하지 말아야 할 것"도 채점합니다.** 큰 파일만 지우고 다른 파일은 남았는지, 범인 프로세스만 죽이고 웹 서버는 살아 있는지.
4. **실패 메시지가 다음 행동을 알려줍니다.** `fail "... (지금 적힌 값: '$got')"` 처럼 무엇이 틀렸는지 보여주세요.
5. **함정 하나.** 대소문자(`*.JPG`), 숨김 폴더, 문자열과 숫자 비교처럼 실무에서 실제로 걸리는 포인트를 하나쯤 넣으면 기억에 오래 남습니다. 힌트에서는 그 함정을 꼭 짚어 주세요.

### 힌트 (hints.md)

```markdown
첫 번째 힌트: 방향만 알려주기
---
두 번째 힌트: 쓸 명령어 알려주기
---
마지막 힌트: 거의 정답
```

### 검증

```bash
lab validate                # 필수 파일, YAML, CRLF, 함정 머리 주석, 문서 형식 검사
lab test linux/10           # 1) 풀기 전 check 가 실패하는지
                            # 2) solution.sh 가 성공하는지
                            # 3) 풀이 후 check 가 통과하는지
                            # 4) traps/ 의 함정은 기대한 줄에서 실패하고, 변형은 통과하는지
lab test linux              # 환경 전체
lab test linux --no-traps   # 1~3 만 (빠르게)
lab start linux/10          # 직접 풀어 보기
```

`lab validate` 의 문서 형식 검사는 **화면에서 실제로 깨져 보이는** 실수를 잡아요 ([`src/lint.js`](../src/lint.js)).

| 오류 | 이렇게 고치세요 |
|---|---|
| 표의 칸 수가 머리글과 다름 | 표 안의 코드에 든 파이프 앞에 역슬래시 (아래 예) |
| 인라인 코드 안의 `` \` `` | 인라인 코드 안에서는 이스케이프가 안 돼요. ``` `` 백틱 두 개로 감싸기 `` ``` 나 코드 블록으로 |
| 닫히지 않은 인라인 코드·코드 블록 | 짝을 맞추세요 |
| scenario.yaml 필드, `# 제목`, 빈 힌트 | 채우세요 |

```markdown
| 명령어 | 하는 일 |
|---|---|
| `ls \| wc -l` | 파일 개수 (화면에는 역슬래시 없이 보여요) |
```

해설·모범 풀이가 없거나, 힌트가 2~6개가 아니거나, `## 목표` 가 없으면 경고(⚠)만 보여요.

### 함정·변형 테스트 (traps/)
모범 풀이가 통과하는 것만으로는 부족해요. **틀린 풀이가 통과하는** 채점이 가장 흔한 결함이에요. 학습자가 실제로 저지를 법한 실수를 `traps/` 에 하나씩 적어 두면, `lab test` 가 매번 그 실수가 **정확한 이유로** 실패하는지 확인해요.

```bash
# traps/no-append.sh  (모범 풀이와 같은 종류: .sh 또는 .ps1)
# 설명: usermod 에 -a 를 빼면 learner 가 designers 그룹에서 빠진다
# 실패해야: designers                ← 채점 출력의 ✘ 줄에 이 문구가 있어야 함 (여러 줄 가능)
sudo useradd -m -s /bin/bash kim
sudo usermod -G webdev learner
...
```

| 머리 주석 | 뜻 |
|---|---|
| `# 설명: ...` | 필수. 무엇을 확인하는지 |
| `# 실패해야: 문구` | 채점이 실패하고, 이 문구가 든 ✘ 줄이 있어야 한다 |
| `# 통과해야` | 다르게 풀어도 맞는 풀이(변형). 채점이 통과해야 한다 |
| `# 모범 풀이 먼저` | 모범 풀이를 실행한 뒤 이 스크립트를 실행한다 ("다 풀고 나서 이것까지 하면?") |

- 스크립트는 학습자 권한으로, 실습마다 **새 컨테이너**에서 실행돼요. 중간 명령이 실패해도 끝까지 가요(일부러 실패하는 명령도 있으니까).
- 문구는 ✘ 줄의 **일부**만 쓰세요. 무작위 값(IP, 이름)이 들어가는 부분은 빼고요.
- 함정 하나가 컨테이너 하나라 시간이 들어요. 시나리오마다 2~5개, 서로 다른 실수를 고르세요.
- 채점을 고칠 때는 **먼저 함정을 만들어 실패(= 지금은 통과돼 버림)를 재현**하고, 채점을 고쳐서 그 함정이 실패로 바뀌는 걸 확인하세요.

`lab test` 는 학습 기록을 남기지 않습니다. GitHub Actions에서도 모든 시나리오에 대해 `lab test`(함정 포함)가 실행됩니다([.github/workflows/scenarios.yml](../.github/workflows/scenarios.yml)).

---

## 2. 환경 만들기

```
envs/kubectl/
├── env.yaml
└── Dockerfile    (그 밖에 이미지에 넣을 파일)
```

### env.yaml

```yaml
name: Kubernetes (kubectl)
description: kubectl로 파드, 디플로이먼트, 로그 다루기
order: 40                         # 목록 순서
# 아래는 생략 시 기본값
shell: [bash, -l]                 # 학습자 셸 실행 명령
user: learner                     # 학습자 계정
workdir: /home/learner
history: /home/learner/.bash_history   # 채점 후 "내가 입력한 명령어"로 보여줄 파일
hostname: lab
# command: [sleep, infinity]      # 컨테이너 메인 프로세스 (서비스를 띄워야 하면 변경)

icon: ☸️                           # 웹 화면에 보일 아이콘
short: K8s                        # 왼쪽 환경 탭에 보일 짧은 이름
categories:                       # 시나리오 묶음. 나열한 순서대로 보여준다
  - id: pods
    name: 파드 다루기
    icon: 📦
    description: 상태 확인, 로그, 재시작
  - id: deploy
    name: 배포와 롤백
    icon: 🚀
    description: 스케일, 업데이트, 되돌리기
```

컨테이너 자원과 권한도 환경별로 바꿀 수 있어요 (Docker 환경 예시):
```yaml
privileged: true                  # 컨테이너 안에서 dockerd 를 돌려야 할 때만
volumes: [/var/lib/docker]        # 익명 볼륨 (실습 종료 시 함께 삭제)
memory: 1536                      # MB (기본 768)
cpus: 2                           # 기본 1
command: [start-dockerd]           # 이미지에 넣은 시작 스크립트 (envs/docker/start-dockerd.sh)
```
Docker 환경의 시나리오는 `setup.sh` 에서 `source /usr/local/lib/lab-docker.sh` 후 `wait_docker`, `ensure_busybox`, `build_image 태그 [폴더] <<'EOF' ... EOF` 를 쓸 수 있어요.

`history` 는 목록으로 여러 개를 줄 수도 있어요 (예: SQL 환경은 bash 기록과 sqlite3 셸 기록을 함께 모음).

`env.yaml` 은 이미지 빌드에 쓰이지 않으므로, 이름·설명·카테고리를 바꿔도 이미지를 다시 빌드하지 않습니다.

### Dockerfile 규칙

엔진이 기대하는 것은 네 가지뿐입니다.

1. `bash`, `sh` 가 있을 것 (setup/check 는 bash로 실행)
2. `env.yaml` 의 `user` 계정이 있을 것
3. 학습자가 컨테이너 안에서 `check` 를 쓰려면 그 계정이 비밀번호 없이 `sudo` 가능할 것
4. 학습 기록을 남기려면 셸이 명령어 기록 파일을 즉시 쓸 것. bash는 엔진이 `/etc/profile.d` 로 설정해 주고, PowerShell은 PSReadLine이 기본으로 그렇게 합니다.

[`envs/linux/Dockerfile`](../envs/linux/Dockerfile) 을 복사해서 시작하는 것을 추천합니다. bash가 아닌 셸을 쓰는 예시는 [`envs/powershell`](../envs/powershell) 을 보세요(셸 시작 시 안내 문구를 `profile.ps1` 로 출력).

`Dockerfile` 이나 환경 폴더 안 파일이 바뀌면 다음 `lab start` 때 이미지가 자동으로 다시 빌드됩니다.

#### 가짜 AWS(moto) 보정
moto 가 실제 AWS 와 다르게 동작해서 학습자를 헷갈리게 하는 곳은 [`envs/aws/patch-moto.py`](../envs/aws/patch-moto.py) 에서 고쳐요. 보정을 더하면 [`envs/aws/patch-check.sh`](../envs/aws/patch-check.sh) 에 그 동작을 확인하는 줄도 함께 더하세요. 이미지 빌드 때 실행돼서, moto 버전을 올렸다가 보정이 깨지면 **어느 보정이 깨졌는지** 보여 주고 빌드를 멈춰요.

### 아이디어

| 환경 | 연습할 수 있는 상황 |
|---|---|
| `sql` 확장 (JOIN, 인덱스) | 느린 쿼리 찾기, 테이블 합치기, 백업/복원 |
| `docker` (Docker-in-Docker) | 죽은 컨테이너 로그 보기, 포트 충돌, 이미지 정리 |
| `kubectl` (kind/k3s) | CrashLoopBackOff 원인 찾기, 스케일, 롤백 |
| `aws` 확장 | Config 규칙, Systems Manager Run Command, Transit Gateway, Cost Explorer 이상 탐지 (CloudFormation·Step Functions·CloudTrail·S3 Object Lock 은 가짜 AWS 지원이 약해 보류) |
| `network` | `curl`, `dig`, `ss` 로 연결 문제 진단 |
| `vim` | 파일 편집 미션 |
| `script` 확장 | 로그 파싱 스크립트, CSV→엑셀 차트, 저장된 웹 페이지에서 정보 뽑기 |
