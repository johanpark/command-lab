# 해설

```bash
cd ~/api
git blame config.js              # 전부 '코드 포맷 정리' 커밋... (함정)
git blame -w config.js           # 공백 무시 → 진짜 바꾼 커밋
git log -S 'TIMEOUT_MS: 300,' --oneline   # 또는 pickaxe
git show <해시>                   # 무슨 의도였는지 메시지와 변경 확인
sed -i 's/TIMEOUT_MS: 300,/TIMEOUT_MS: 3000,/' config.js
git commit -am "타임아웃 3000ms 로 되돌림"
```

## 기록 수사 도구 모음
| 명령어 | 언제 |
|---|---|
| `git blame -w -C 파일` | 줄의 출처. `-w` 공백 무시, `-C` 다른 파일에서 옮겨 온 코드도 추적 |
| `git blame -L 10,20 파일` | 10~20번째 줄만 |
| `git log -S '문자열'` | 문자열이 생기거나 사라진 커밋 |
| `git log -G '정규식'` | 그 패턴이 들어간 줄이 바뀐 커밋 (개수가 같아도) |
| `git log -L '/TIMEOUT_MS/,+1:config.js'` | 특정 줄의 변천사를 diff 로 |
| `git log --follow -p 파일` | 이름이 바뀐 파일까지 따라가며 |

## 포맷 커밋이 blame 을 가리지 않게
팀에서 대규모 포맷 정리를 했다면 그 커밋 해시를 `.git-blame-ignore-revs` 파일에 적어 두고
```bash
git config blame.ignoreRevsFile .git-blame-ignore-revs
```
하면 blame 이 그 커밋을 건너뛰어요. GitHub 의 blame 화면도 이 파일을 알아봐요.

## 같은 실수를 막으려면
- 설정값에 **단위를 이름에** (`TIMEOUT_MS`) 넣은 건 좋은 습관. 거기에 범위 검사(`if (TIMEOUT_MS < 1000) throw ...`) 를 더하면 0 하나 빠뜨리는 실수를 시작할 때 잡아요.
- 설정 변경도 코드 리뷰를 거치게
