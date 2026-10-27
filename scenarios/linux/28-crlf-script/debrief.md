# 해설

```bash
cd ~/deploy
file *.sh lib/*.sh               # deploy.sh: ... with CRLF line terminators
cat -A deploy.sh | head -2       # #!/usr/bin/env bash^M$
sed -i 's/\r$//' *.sh lib/*.sh
./deploy.sh
```

## 에러 메시지로 알아보기
| 메시지 | 뜻 |
|---|---|
| `/usr/bin/env: 'bash\r': No such file or directory` | 첫 줄(shebang) 끝에 `\r` |
| `$'\r': command not found` | 빈 줄이 사실 `\r` 한 글자 |
| `syntax error near unexpected token $'do\r'` | `do`, `then` 뒤에 `\r` |
| `cd: $'dir\r': No such file or directory` | 경로 끝에 `\r` |

## 다시는 안 겪으려면
- **Git**: 저장소에 `.gitattributes` 를 두면 Windows 에서 체크아웃해도 스크립트는 LF 로 유지돼요. (이 command-lab 저장소도 그렇게 해 뒀어요)
  ```
  *.sh text eol=lf
  ```
- **편집기**: VS Code 오른쪽 아래 `CRLF` 를 눌러 `LF` 로 바꿀 수 있어요.
- **도구**: `dos2unix 파일` (설치: `sudo apt install dos2unix`)

## 주의
`tr -d '\r' < a.sh > a.sh` 처럼 같은 파일로 바로 쓰면 **파일이 비어요.** 새 파일로 쓴 뒤 옮기면 이번엔 **실행 권한이 사라질** 수 있으니 `chmod +x` 를 잊지 마세요. `sed -i` 는 둘 다 신경 쓸 필요가 없어요.
