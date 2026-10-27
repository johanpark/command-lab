# command not found

배포 도구 `deploytool` 을 설치했다는데 실행이 안 됩니다.

```
$ deploytool --version
deploytool: command not found
```

설치 담당자 말로는 `~/tools/bin` 에 넣어 뒀다고 하네요.

## 목표
1. `deploytool` 을 **어느 폴더에서든 이름만으로** 실행할 수 있게 하세요.
2. 터미널을 **새로 열어도** 계속 그렇게 동작해야 합니다.
3. `deploytool --version` 의 출력을 `~/answer.txt` 에 저장하세요.
4. 기존 명령어(`ls`, `grep` 등)도 계속 잘 동작해야 합니다.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `echo $PATH` | 명령어를 찾는 폴더 목록 (`:` 로 구분) |
| `which 명령` | 명령어가 실제로 어디 있는지 |
| `export PATH="$PATH:폴더"` | PATH 에 폴더 추가 (지금 터미널에서만) |
| `~/.bashrc` | 새 터미널이 열릴 때마다 실행되는 설정 파일 |
| `source ~/.bashrc` | 설정 파일을 지금 바로 다시 읽기 |
