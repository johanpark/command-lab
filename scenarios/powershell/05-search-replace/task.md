# 설정 파일 검색·일괄 수정

`~/configs` 에 서비스 설정 파일(`.ini`)이 여러 개 있어요. 보안 점검을 해야 합니다.

## 목표
1. 비밀번호가 **평문으로** 적힌 파일(`password=` 가 들어 있는 줄이 있는 파일)의 **파일 이름**(예: `billing.ini`)을 한 줄에 하나씩 `~/leaks.txt` 에 저장하세요. (순서 상관없음)
2. 모든 `.ini` 파일에서 `http://` 를 **`https://`** 로 바꾸세요. 다른 내용은 그대로 둬야 해요.

## 써볼 cmdlet
| cmdlet | 하는 일 |
|---|---|
| `Select-String -Path ~/configs/*.ini -Pattern '찾을것'` | 여러 파일에서 찾기 (grep 같은 것) |
| `... \| Select-Object -ExpandProperty Filename -Unique` | 찾은 파일 이름만, 중복 없이 |
| `(Get-Content 파일) -replace '옛', '새'` | 줄마다 바꾸기 (정규식) |
| `Set-Content 파일 값` | 파일에 쓰기 |
| `Get-ChildItem ~/configs/*.ini \| ForEach-Object { ... }` | 파일마다 반복 (`$_` 가 지금 파일) |
