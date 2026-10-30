#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
for q in log-cleanup-jobs report-jobs; do aws sqs create-queue --queue-name $q >/dev/null; done
arn() { echo "arn:aws:sqs:ap-northeast-2:123456789012:$1"; }
aws events put-rule --name log-cleanup --schedule-expression "cron(0 4 * * ? *)" --description "매일 새벽 4시 로그 정리" >/dev/null
aws events put-targets --rule log-cleanup --targets "Id=cleanup,Arn=$(arn log-cleanup-jobs)" >/dev/null
aws events put-rule --name weekly-invoice --schedule-expression "cron(0 0 ? * MON *)" --description "매주 월요일 오전 9시(KST) 청구서 발송" >/dev/null
aws events put-targets --rule weekly-invoice --targets "Id=invoice,Arn=$(arn report-jobs)" >/dev/null
M=$(rand_pick 10 20 30 40); secret_set min "$M"
mkdir -p "$H"
cat > "$H/schedule.md" <<MD
# 예약 작업 정리 (모든 시각은 한국 시간 KST = UTC+9)

| 규칙 이름 | 언제 | 대상 SQS 큐 | 상태 |
|---|---|---|---|
| log-cleanup | **매일 04:00** | log-cleanup-jobs | ⚠️ 실제로는 오후 1시에 돌고 있음! |
| weekly-invoice | 매주 월요일 09:00 | report-jobs | 정상 |
| nightly-sales-report | **평일(월~금) 03:$M** | report-jobs | 🆕 만들어야 함 |

메모: EventBridge 규칙의 cron(...) 은 **UTC** 기준. 형식은 cron(분 시 일 월 요일 연도),
일과 요일 중 하나는 반드시 ? 로 둘 것.
MD
give "$H/schedule.md"
