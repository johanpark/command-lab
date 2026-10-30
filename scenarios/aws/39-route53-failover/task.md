# 서버가 죽으면 예비 서버로 자동 전환 (Route 53 헬스 체크·장애 조치)

지난달 API 서버가 새벽에 죽었는데, 담당자가 일어나서 DNS 를 예비 서버로 바꿀 때까지 **2시간 동안** 서비스가 멈췄어요.
Route 53 이 서버 상태를 계속 확인하다가, 죽으면 **알아서 예비 서버 IP 를 알려 주게** 만들어요. 계획은 `~/failover-plan.md` 에 있어요.

## 목표
1. 운영 서버에 **헬스 체크**를 만드세요. (HTTPS, 443, `/health`, 30초 간격, 3번 실패)
2. 지금 있는 `api` 의 일반 A 레코드를 **장애 조치 레코드 두 개**로 바꾸세요.
   - **PRIMARY**: 운영 서버 IP + 위 헬스 체크
   - **SECONDARY**: 예비 서버 IP
   - 둘 다 TTL 60
3. `www`, `MX` 레코드는 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws route53 create-health-check --caller-reference 아무거나-고유 --health-check-config "IPAddress=..,Port=443,Type=HTTPS,ResourcePath=/health,RequestInterval=30,FailureThreshold=3"` | 헬스 체크 |
| `aws route53 list-health-checks` | 헬스 체크 목록과 ID |
| `aws route53 list-resource-record-sets --hosted-zone-id ID` | 레코드 |
| `aws route53 change-resource-record-sets --hosted-zone-id ID --change-batch file://batch.json` | 레코드 바꾸기 |

장애 조치 레코드는 같은 이름·타입이 두 개라서 **`SetIdentifier`** 로 구분해요:
```json
{"Action": "CREATE", "ResourceRecordSet": {
  "Name": "api.도메인", "Type": "A", "SetIdentifier": "seoul", "Failover": "PRIMARY",
  "TTL": 60, "HealthCheckId": "...", "ResourceRecords": [{"Value": "IP"}]}}
```
> 💡 일반 레코드와 장애 조치 레코드는 **같은 이름으로 같이 있을 수 없어요.** 한 배치 안에서 기존 것을 `DELETE` 하고 새 것 두 개를 `CREATE` 하세요.
