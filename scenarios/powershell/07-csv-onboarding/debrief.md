# 해설

```powershell
Import-Csv ~/onboarding/new-hires.csv |
  Where-Object Status -ne 'cancelled' |
  ForEach-Object {
    $acc = $_.Account.Trim().ToLower()
    $dir = "$HOME/homes/$acc"
    New-Item -ItemType Directory -Force -Path "$dir/Documents", "$dir/Desktop" | Out-Null
    Set-Content "$dir/welcome.txt" "환영합니다, $($_.Name)님! ($($_.Department))"
    $acc
  } | Set-Content ~/created.txt
```

## 손으로 만든 데이터는 항상 정리부터
| 문제 | 정리 |
|---|---|
| 앞뒤 공백 `'  jkim '` | `.Trim()` |
| 대소문자 섞임 `JKim` | `.ToLower()` |
| 취소·중복 행 | `Where-Object`, `Sort-Object -Unique` |
| 빈 줄 | `Where-Object { $_.Account }` |

공백이 들어간 채로 폴더를 만들면 `jkim ` 처럼 **눈에 안 보이는 다른 폴더**가 생겨서, 나중에 "폴더가 있는데 없대요" 같은 이상한 문제가 돼요.

## 문자열 안에 속성 넣기
| 쓴 것 | 결과 |
|---|---|
| `"$($_.Name)님"` | `김민수님` ✅ |
| `"$_.Name님"` | `@{Name=김민수; ...}.Name님` ❌ |
| `"{0}님 ({1})" -f $_.Name, $_.Department` | 형식 문자열도 가능 ✅ |

## 실제 Windows 서버라면
여기서는 폴더만 만들었지만, 실무에서는 같은 반복문 안에서 `New-LocalUser` / `New-ADUser` 로 계정을 만들고 `Set-Acl` 로 그 사람만 쓸 수 있게 권한을 줘요. 실행 전에 `-WhatIf` 로 미리 보기를 꼭 해 보세요.
