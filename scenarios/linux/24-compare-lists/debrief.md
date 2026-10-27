# 해설

```bash
diff -u ~/config-old.conf ~/config-new.conf
# -timeout = 30
# +timeout = 5          ← 같은 이름이 -/+ 둘 다: 값 변경
# -legacy_mode = on     ← - 만: 삭제
# +metrics = enabled    ← + 만: 추가
echo timeout > ~/changed.txt

comm -23 <(sort -u ~/all-users.txt) <(sort -u ~/active-users.txt) > ~/dormant.txt
```

## comm 의 세 칸
```
$ comm A B
a만          ← 1칸: A 에만
	b만      ← 2칸: B 에만
		둘다  ← 3칸: 둘 다
```
`-1`, `-2`, `-3` 으로 칸을 숨겨요. `comm -12` = 둘 다 있는 것(교집합), `comm -23` = A 에만(차집합).

## 함정 포인트
- `comm` 은 입력이 **정렬돼 있다고 가정**해요. 정렬 안 된 파일을 넣으면 경고와 함께 엉뚱한 결과가 나와요.
- `uniq` 도 **붙어 있는** 중복만 지워요. 그래서 거의 항상 `sort | uniq` 또는 `sort -u`.

## 다른 방법
```bash
grep -vxFf ~/active-users.txt ~/all-users.txt | sort -u   # active 에 없는 줄 (정렬 불필요)
diff <(sort -u a) <(sort -u b)                            # 정렬해서 비교
vimdiff a b                                               # 나란히 보기
```
