# 해설

```bash
head ~/logs/app.log                         # 생김새 파악
grep -c ERROR ~/logs/app.log > ~/answer.txt
tail -n 20 ~/logs/app.log > ~/recent.log
grep ERROR ~/logs/app.log > ~/errors.log
```

## 함정 포인트
`grep -i error` (대소문자 무시)를 쓰면 `retry succeeded after previous error` 같은 INFO 줄까지 세어져서 숫자가 틀립니다. **무엇을 찾는지 정확히** 정하는 게 로그 분석의 핵심이에요.

## 더 알아두면 좋은 것
- `tail -f 파일` : 파일에 새로 쓰이는 줄을 실시간으로 보기 (실무에서 정말 자주 씀, `Ctrl+C` 로 종료)
- `grep -n` : 줄 번호도 같이 출력
- `grep -v INFO` : INFO 가 **없는** 줄만
- `grep -E 'ERROR|WARN'` : 둘 중 하나라도 있는 줄
- `less 파일` 안에서 `/ERROR` 로 검색, `n` 으로 다음 결과, `G` 로 맨 끝, `q` 로 종료
