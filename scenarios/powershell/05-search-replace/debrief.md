# 해설

```powershell
Select-String -Path ~/configs/*.ini -Pattern '^password=' |
  Select-Object -ExpandProperty Filename -Unique |
  Set-Content ~/leaks.txt

Get-ChildItem ~/configs/*.ini | ForEach-Object {
  (Get-Content $_.FullName) -replace 'http://', 'https://' |
    Set-Content $_.FullName
}
```

## 함정 포인트 1: 같은 파일 읽고 쓰기
```powershell
Get-Content f | Set-Content f        # ❌ 읽는 중에 쓰기
(Get-Content f) | Set-Content f      # ✅ 괄호 = 먼저 전부 읽어서 메모리에
```
- Windows: `The process cannot access the file ... because it is being used by another process` 에러
- 리눅스: 잠금이 없어서 작은 파일은 우연히 되기도 하지만, 큰 파일은 읽는 도중 덮어써져 **내용이 깨질 수 있어요.**

bash 의 `sed 's/a/b/' f > f` 가 파일을 비워 버리는 것과 같은 종류의 함정이에요 (그래서 sed 에는 `-i` 가 있죠).

## 함정 포인트 2: 주석
`# password=  (vault 에서 주입)` 은 비밀번호가 아니에요. `^` (줄의 시작)로 패턴을 고정해야 정확해요.

## -replace 는 정규식
```powershell
'a.b' -replace '.', '-'          # '---' (점은 "아무 글자")
'a.b' -replace '\.', '-'         # 'a-b'
'a.b'.Replace('.', '-')          # 'a-b' (문자 그대로 바꾸기)
'v1.2' -replace 'v(\d+)', 'ver$1' # 'ver1.2' (그룹 재사용)
```

## bash 와 비교
| 하고 싶은 일 | bash | PowerShell |
|---|---|---|
| 여러 파일 검색 | `grep -l 'x' *.ini` | `Select-String -Path *.ini -Pattern x -List` |
| 일괄 치환 | `sed -i 's#a#b#g' *.ini` | `(Get-Content f) -replace 'a','b' \| Set-Content f` |
