# CSV 명단으로 폴더 한꺼번에 만들기

다음 주 입사자 명단 `~/onboarding/new-hires.csv` 가 왔어요. 사람마다 공용 서버에 개인 폴더를 만들어 줘야 해요. 열 명이 넘으니 손으로 하긴 귀찮죠.

## 목표
명단의 **각 입사자**마다
1. `~/homes/<계정>` 폴더를 만들고, 그 안에 **`Documents`**, **`Desktop`** 폴더를 만드세요.
2. `~/homes/<계정>/welcome.txt` 에 정확히 이 한 줄을 쓰세요: `환영합니다, <이름>님! (<부서>)`
   - 예: `환영합니다, 김민수님! (플랫폼팀)`
3. 만든 계정 이름을 한 줄에 하나씩 `~/created.txt` 에 저장하세요. (순서 상관없음)

단,
- `Status` 가 **`cancelled`** 인 사람(입사 취소)은 만들지 마세요.
- 계정 이름은 **앞뒤 공백 없이, 모두 소문자**로. (명단이 사람 손으로 만든 거라 지저분해요)

## 써볼 cmdlet
| cmdlet | 하는 일 |
|---|---|
| `Import-Csv 파일` | CSV 를 객체 목록으로 (`$_.Name`, `$_.Account` …) |
| `Import-Csv 파일 \| Format-Table` | 표로 보기 |
| `Where-Object Status -ne 'cancelled'` | 조건으로 거르기 |
| `ForEach-Object { ... }` | 한 줄씩 처리 (`$_` = 지금 줄) |
| `$s.Trim()` / `$s.ToLower()` | 앞뒤 공백 제거 / 소문자로 |
| `New-Item -ItemType Directory -Force -Path 경로` | 폴더 만들기 (`-Force` 는 상위 폴더까지, 이미 있어도 OK) |
| `Set-Content 파일 '내용'` | 파일 쓰기 |
