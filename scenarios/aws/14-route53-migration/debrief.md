# 해설

```bash
Z=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text)
ZN=$(aws route53 list-hosted-zones --query 'HostedZones[0].Name' --output text)
OLD=13.125.x.x   # 메모의 기존 IP
NEW=$(aws ec2 describe-instances --filters Name=tag:Name,Values=web-new --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
# 기존 IP 를 가리키는 A 레코드만 골라 UPSERT 배치를 만들고 m CNAME 을 덧붙인다
aws route53 list-resource-record-sets --hosted-zone-id $Z --output json | jq --arg o $OLD --arg n $NEW --arg zn $ZN '{Changes:
  ([.ResourceRecordSets[] | select(.Type=="A" and any(.ResourceRecords[]; .Value==$o))
    | {Action:"UPSERT", ResourceRecordSet:{Name, Type, TTL, ResourceRecords:[{Value:$n}]}}]
   + [{Action:"UPSERT", ResourceRecordSet:{Name:("m."+$zn), Type:"CNAME", TTL:300, ResourceRecords:[{Value:("www."+$zn)}]}}])}' > batch.json
aws route53 change-resource-record-sets --hosted-zone-id $Z --change-batch file://batch.json
```

## 레코드 종류
| 종류 | 뜻 | 예 |
|---|---|---|
| A | 이름 → IPv4 주소 | `www` → `54.180.1.2` |
| CNAME | 이름 → **다른 이름** (별칭) | `m` → `www.도메인` |
| MX | 메일 받을 서버 | `10 aspmx...` |
| TXT | 소유 인증, SPF 같은 메모 | `"v=spf1 ..."` |

- `m` 을 A 레코드로 새 IP 를 직접 넣어도 지금은 동작하지만, 다음 이사 때 또 찾아 고쳐야 해요. **CNAME 은 www 만 바꾸면 따라와요.**
- 도메인 자체(apex, `shop.com.`)에는 CNAME 을 쓸 수 없어요 (MX·TXT 와 같이 있어야 해서). 그래서 apex 는 A 레코드, 또는 Route 53 의 **Alias** 를 써요.

## 실제 이사할 때 순서
1. **며칠 전에 TTL 을 낮춰요** (예: 300 → 60). TTL 은 다른 DNS 서버가 답을 캐시하는 시간이라, 높으면 바꾼 뒤에도 한동안 옛 서버로 가요.
2. 레코드 변경 → `dig +short www.도메인` 으로 확인
3. 기존 서버는 **TTL 이 지나고 접속이 0 이 될 때까지** 바로 끄지 말기 (로그로 확인)
4. 다 끝나면 TTL 을 다시 올리기

## 실무 팁
- 실제 서비스에서는 EC2 공인 IP 를 직접 넣기보다 **Elastic IP**(서버를 바꿔도 유지) 나 **로드 밸런서(ALB) Alias** 를 가리키게 해요. 그러면 서버를 바꿀 때 DNS 를 안 건드려도 돼요.
- `change-resource-record-sets` 는 배치 안의 변경을 **전부 성공하거나 전부 실패** 해요. 여러 레코드를 한 번에 바꾸는 게 안전한 이유예요.
