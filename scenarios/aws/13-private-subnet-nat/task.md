# 프라이빗 서버가 인터넷에 못 나가요 (라우팅 테이블, NAT)

`shop-vpc` 안의 앱 서버 **app-1**, **app-2** 에서 `apt update`, `pip install`, 결제 API 호출이 전부 **타임아웃**이에요.
두 서버는 외부에서 직접 접속하면 안 되는 **프라이빗 서브넷**(`app-a`, `app-c`)에 있어요.

```
인터넷 ── IGW ── [public-a / public-c]  (NAT 게이트웨이가 여기 있음)
                       │
                  [app-a / app-c]  ← app-1, app-2 (공인 IP 없음)
```

## 목표
1. 프라이빗 서브넷 **`app-a` 와 `app-c` 모두** 바깥(`0.0.0.0/0`)으로 가는 트래픽이 **사용 중인 NAT 게이트웨이**를 거쳐 나가게 하세요.
2. 프라이빗 서브넷을 **인터넷 게이트웨이(IGW)에 직접** 연결하면 안 돼요.
3. 퍼블릭 서브넷(`public-a`, `public-c`)의 경로는 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-...` | 서브넷 목록 |
| `aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-...` | 라우팅 테이블과 연결된 서브넷 |
| `aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=vpc-...` | NAT 게이트웨이 (`--filter` 단수형 주의!) |
| `aws ec2 create-route --route-table-id rtb-... --destination-cidr-block 0.0.0.0/0 --nat-gateway-id nat-...` | 경로 추가 |
| `aws ec2 associate-route-table --route-table-id rtb-... --subnet-id subnet-...` | 서브넷에 라우팅 테이블 연결 |

> 💡 서브넷에 라우팅 테이블이 **명시적으로 연결돼 있지 않으면** VPC 의 **기본(main) 라우팅 테이블**을 따라가요.
