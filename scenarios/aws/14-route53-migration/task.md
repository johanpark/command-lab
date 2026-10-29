# 새 서버로 이사하기 (Route 53 DNS 레코드)

오늘 웹 서비스를 새 EC2 서버로 옮겨요. 서버는 준비됐고, 이제 **도메인이 새 서버를 가리키도록** Route 53 의 DNS 레코드만 바꾸면 돼요.
작업 메모는 `~/migration.md` 에 있어요.

## 목표
1. 기존 서버 IP 를 가리키는 **A 레코드를 모두** 찾아서 새 서버(`web-new`)의 **공인 IP** 로 바꾸세요.
2. `m.도메인` 을 **CNAME** 으로 추가해서 `www.도메인` 을 가리키게 하세요.
3. 메일(MX), 인증(TXT), `admin`, `status` 레코드는 **그대로** 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws route53 list-hosted-zones` | 내 도메인(호스팅 영역) 목록과 ID |
| `aws route53 list-resource-record-sets --hosted-zone-id ID` | 레코드 목록 |
| `aws ec2 describe-instances --filters Name=tag:Name,Values=web-new` | 새 서버 정보 (`PublicIpAddress`) |
| `aws route53 change-resource-record-sets --hosted-zone-id ID --change-batch file://batch.json` | 레코드 바꾸기 |

`batch.json` 모양 (여러 개를 한 번에 바꿀 수 있어요):
```json
{"Changes": [
  {"Action": "UPSERT", "ResourceRecordSet": {
     "Name": "www.도메인", "Type": "A", "TTL": 300,
     "ResourceRecords": [{"Value": "새 IP"}]}}
]}
```
> `UPSERT` = 있으면 바꾸고 없으면 만들기. 도메인 자체(`도메인.`, 앞에 아무것도 없는 것)도 레코드예요!
