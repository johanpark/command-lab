# 해설

```bash
~/tools/bin/deploytool --version                           # 전체 경로로는 동작
echo $PATH                                                 # ~/tools/bin 이 없음
echo 'export PATH="$PATH:$HOME/tools/bin"' >> ~/.bashrc    # 영구 설정
source ~/.bashrc                                           # 지금 셸에 반영
which deploytool                                           # /home/learner/tools/bin/deploytool
deploytool --version > ~/answer.txt
```

## 기억할 것
- **command not found** = 프로그램이 없거나, **PATH 에 그 폴더가 없거나** 둘 중 하나예요. `which`/`command -v` 로 확인하세요.
- `export` 는 **지금 열린 셸에만** 적용됩니다. 영구 설정은 `~/.bashrc` (zsh 라면 `~/.zshrc`).
- `>>` (이어 붙이기) 대신 `>` 를 쓰면 `.bashrc` 전체가 지워져요!
- 작은따옴표 `'...'` 로 감싸야 `$PATH` 가 지금 값으로 펼쳐지지 않고 글자 그대로 저장됩니다.

## 다른 환경에서는
| 환경 | 설정 파일 |
|---|---|
| 맥 (zsh 기본) | `~/.zshrc` |
| 리눅스 bash | `~/.bashrc` |
| Windows PowerShell | `$PROFILE` 파일, 또는 시스템 환경 변수 편집 |
