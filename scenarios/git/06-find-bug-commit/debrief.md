# 해설

```bash
cd ~/calculator
./test.sh                         # ✘ add
git blame calc.sh                 # add 줄 → a1b2c3d (박개발 2026-10-12)
git log -L '/^add/,+1:calc.sh' --oneline   # add 줄의 변경 이력
git show a1b2c3d                  # 주석 수정 + add 를 a - b 로
echo a1b2c3d > ~/answer.txt
git revert a1b2c3d                # 되돌리는 새 커밋 생성
./test.sh                         # 모두 ✔
git log --oneline                 # 맨 위에 Revert "코드 스타일 정리"
```

## revert vs reset
| | `git revert 커밋` | `git reset --hard 커밋` |
|---|---|---|
| 하는 일 | 반대 내용의 **새 커밋 추가** | 기록을 그 시점으로 **잘라냄** |
| 그 뒤 커밋들 | 살아 있음 | 함께 사라짐 |
| 공유한(push 한) 기록 | ✅ 안전 | ❌ 팀원들 기록과 어긋남 |

## 범인 찾기 도구
- `git log -S '코드'` : 그 문자열 개수가 바뀐 커밋 (일명 pickaxe). 이번처럼 같은 코드(`$1 - $2`)가 sub 에도 있으면 sub 를 만든 커밋까지 나와서 헷갈려요.
- `git log -G '정규식'` : 정규식에 맞는 줄이 바뀐 커밋
- `git blame -L 3,3 calc.sh` : 3번째 줄만 누가 언제
- `git bisect` : "여기선 됐고 여기선 안 된다"를 알려주면 이진 탐색으로 범인 커밋을 찾아줌. 커밋이 수백 개일 때 강력해요.
  ```bash
  git bisect start; git bisect bad HEAD; git bisect good <잘 되던 커밋>
  git bisect run ./test.sh      # 자동으로 찾아줌
  ```
