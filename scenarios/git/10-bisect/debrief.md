# 해설

```bash
cd ~/pricing
git log --oneline | tail -1           # 첫 커밋 (정상)
git bisect start
git bisect bad                        # 지금은 깨짐
git bisect good e1f2a3b               # 첫 커밋은 정상
git bisect run ./test.sh              # 자동 탐색
# a1b2c3d... is the first bad commit
echo a1b2c3d > ~/answer.txt
git bisect reset                      # 원래 위치로
git show a1b2c3d                      # 무엇이 바뀌었나
```

## 이진 탐색의 힘
| 커밋 수 | 하나씩 확인 | bisect |
|---|---|---|
| 40 | 최대 40번 | 약 6번 |
| 1,000 | 최대 1,000번 | 약 10번 |

## bisect run 의 약속
테스트 스크립트의 **종료 코드**로 판단해요.
- `0` → good, `1~124` → bad, `125` → 이 커밋은 판단 불가(skip)
그래서 테스트·빌드 스크립트가 실패 시 0 이 아닌 코드를 돌려주는 게 중요해요 (`linux/27`, `linux/29` 시나리오와 연결).

## 메시지가 도움이 안 될 때
이번 범인의 메시지는 "작은 수정" 같은 무해한 말이었어요. `git blame`, `git log -S` 로도 찾을 수 있지만, **어떤 코드가 원인인지도 모를 때** (성능 저하, 이상한 동작) bisect 는 테스트 하나만 있으면 범인을 찾아 줘요.
