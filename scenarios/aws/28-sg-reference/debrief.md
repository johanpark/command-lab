# 해설

```bash
# IP 대역으로 열린 규칙 지우기
aws ec2 revoke-security-group-ingress --group-id <db-sg> --security-group-rule-ids <0.0.0.0/0 규칙> <172.31.0.0/16 규칙>
aws ec2 revoke-security-group-ingress --group-id <cache-sg> --security-group-rule-ids <0.0.0.0/0 규칙>
# 보안 그룹을 출처로
aws ec2 authorize-security-group-ingress --group-id <db-sg> --protocol tcp --port 5432 --source-group <app-sg>
aws ec2 authorize-security-group-ingress --group-id <db-sg> --protocol tcp --port 5432 --source-group <bastion-sg>
```

## 보안 그룹 체인
```
인터넷 ──443──▶ [alb-sg] ──8080──▶ [app-sg] ──5432──▶ [db-sg]
                                       └──6379──▶ [cache-sg]
사무실 ──22──▶ [bastion-sg] ─────────5432──▶ [db-sg]
```
- "출처 = app-sg" 는 **app-sg 가 붙어 있는 네트워크 인터페이스에서 오는 트래픽**이라는 뜻이에요. 앱 서버가 10대로 늘든 IP 가 바뀌든 규칙을 고칠 필요가 없어요.
- VPC 전체(172.31.0.0/16)를 허용하면 같은 VPC 의 **아무 서버**(테스트 서버, 침해된 서버…)나 DB 에 붙을 수 있어요.

## 실무 팁
- 보안 그룹은 "허용" 만 있고 "거부" 가 없어요. 규칙을 지우는 것 = 막는 것.
- 규칙마다 `Description` 을 꼭 적어 두세요 (`temp-debug` 같은 임시 규칙이 남는 이유가 대개 설명이 없어서예요).
- AWS Config 의 `restricted-common-ports`, Security Hub 같은 도구가 0.0.0.0/0 에 열린 DB 포트를 자동으로 찾아 줘요.
