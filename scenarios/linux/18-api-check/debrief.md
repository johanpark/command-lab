# 해설

```bash
cat ~/endpoints.txt
while read url; do
  echo "$(curl -s -o /dev/null -w '%{http_code}' "$url") $url"
done < ~/endpoints.txt
# 200 http://localhost:8000/api/health.json
# 404 http://localhost:8000/api/orders.json   ← 범인
echo http://localhost:8000/api/orders.json > ~/answer.txt

curl -s http://localhost:8000/api/users.json | jq -r '.[] | select(.role == "admin") | .email' > ~/admins.txt
```

## curl 옵션 정리
| 옵션 | 뜻 |
|---|---|
| `-s` | 진행 표시줄 숨기기 (silent) |
| `-i` / `-I` | 헤더 포함 / 헤더만 |
| `-o 파일` | 본문을 파일로 (`/dev/null` 이면 버리기) |
| `-w '%{http_code}'` | 끝나고 상태 코드 출력 |
| `-X POST -d '{"a":1}' -H 'Content-Type: application/json'` | JSON 보내기 |
| `-L` | 리다이렉트 따라가기 |

## jq 자주 쓰는 패턴
```bash
jq length                                 # 배열 길이
jq '.[] | .name'                          # 각 항목의 name
jq -r '.[] | "\(.name)\t\(.role)"'        # 원하는 형식으로
jq '[.[] | select(.active)] | length'     # 활성 사용자 수
jq 'group_by(.role) | map({role: .[0].role, n: length})'  # 역할별 인원
```
