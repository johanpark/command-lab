# 해설

```bash
HC=$(aws route53 create-health-check --caller-reference api-$(date +%s) \
  --health-check-config "IPAddress=$P,Port=443,Type=HTTPS,ResourcePath=/health,RequestInterval=30,FailureThreshold=3" \
  --query HealthCheck.Id --output text)
aws route53 change-resource-record-sets --hosted-zone-id $Z --change-batch file://batch.json   # DELETE 1 + CREATE 2
```

## 동작 방식
```
Route 53 헬스 체커(전 세계 여러 곳) ──30초마다──▶ https://운영IP/health
  정상 → api.도메인 = 운영 IP (PRIMARY)
  3번 연속 실패 → api.도메인 = 예비 IP (SECONDARY)  ← 사람 손 없이
  다시 정상 → 자동으로 PRIMARY 로 복귀
```
- 실제로 넘어가는 시간 ≈ 감지(30초 × 3) + **TTL**(사용자 쪽 DNS 캐시). TTL 300 이면 감지 후에도 최대 5분 동안 죽은 서버로 가요. 그래서 60 으로 낮췄어요.
- 헬스 체크 경로는 **앱이 진짜 살아 있는지** 보여 주는 곳이어야 해요. `/` 는 웹 서버만 살아 있어도 200 을 줄 수 있어서, DB 연결까지 확인하는 `/health` 가 좋아요.

## 일반 레코드 → 장애 조치 레코드
같은 이름·타입에 일반 레코드와 라우팅 정책 레코드(장애 조치, 가중치, 지연 시간…)는 **같이 있을 수 없어요.** 그래서 한 배치 안에서 DELETE + CREATE 를 해요. 배치는 **전부 성공하거나 전부 실패**라서, 중간에 레코드가 비는 순간이 없어요.

## 실무 팁
- 헬스 체크에 **CloudWatch 알람**을 걸어서 "운영 서버가 죽어서 예비로 넘어갔다" 는 걸 사람도 알게 하세요.
- 예비 서버가 데이터가 최신이 아니면 넘어가도 쓸모가 없어요. DB 복제(교차 리전 읽기 복제본 등)와 함께 계획해야 해요.
- ALB 를 쓰면 IP 대신 **Alias 레코드 + EvaluateTargetHealth** 로 ALB 상태를 그대로 쓸 수 있어요.
