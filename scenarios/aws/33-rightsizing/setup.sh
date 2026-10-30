#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret; ami=$(lab_ami)
: > $S/plan   # id<TAB>이름<TAB>지금타입<TAB>기대타입
inst() { # 이름 타입 평균 최대 기대타입 [DoNotResize]
  local tags="{Key=Name,Value=$1}"; [ -n "$6" ] && tags+=",{Key=DoNotResize,Value=true}"
  local i; i=$(aws ec2 run-instances --image-id "$ami" --instance-type "$2" --tag-specifications "ResourceType=instance,Tags=[$tags]" --query 'Instances[0].InstanceId' --output text)
  python3 - "$i" "$3" "$4" > $S/m.json <<'PY'
import json, random, sys, datetime as dt
iid, avg, mx = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
now = dt.datetime.now(dt.timezone.utc).replace(minute=0, second=0, microsecond=0)
vals = [max(0.3, random.gauss(avg, avg * 0.25)) for _ in range(168)]
if mx >= 40 and avg < 10:          # 밤에만 바쁜 배치: 매일 새벽 2시간
    for d in range(7):
        for h in (18, 19):
            vals[d * 24 + h] = random.uniform(mx - 15, mx)
vals = [min(v, mx - 1) for v in vals]
vals[random.randrange(168)] = mx
scale = avg / (sum(vals) / len(vals))
vals = [min(mx, round(v * scale, 1)) if v != mx else mx for v in vals]
data = [{"MetricName": "CPUUtilization", "Dimensions": [{"Name": "InstanceId", "Value": iid}],
         "Timestamp": (now - dt.timedelta(hours=167 - k)).strftime('%Y-%m-%dT%H:%M:%SZ'), "Value": v, "Unit": "Percent"}
        for k, v in enumerate(vals)]
print(json.dumps(data))
PY
  # 10KB 가 넘는 요청은 CLI 가 gzip 으로 압축하는데 moto 가 못 읽는다 → 압축 끄기
  AWS_DISABLE_REQUEST_COMPRESSION=true aws cloudwatch put-metric-data --namespace AWS/EC2 --metric-data file://$S/m.json
  printf '%s\t%s\t%s\t%s\n' "$i" "$1" "$2" "$5" >> $S/plan
}
inst web-1      m5.xlarge  $(rand_int 45 60) 88 m5.xlarge
inst web-2      m5.xlarge  $(rand_int 45 60) 91 m5.xlarge
inst batch-1    c5.2xlarge 4 92 c5.2xlarge
inst admin-1    m5.2xlarge 3 12 m5.xlarge
inst report-1   m5.xlarge  6 27 m5.large
inst stg-api-1  t3.large   2 9  t3.medium
inst legacy-erp c5.xlarge  2 8  c5.xlarge yes
rm -f $S/m.json
mkdir -p "$H"
cat > "$H/rightsizing.md" <<'MD'
# 서버 크기 조정 기준 (비용 절감 TF)

**지난 7일** CPU 사용률(CPUUtilization)이
- **평균 10% 미만** 이고
- **최대 40% 미만** 인 서버를

한 단계 작은 타입으로 바꾼다.

| 지금 | 바꿀 타입 |
|---|---|
| m5.2xlarge | m5.xlarge |
| m5.xlarge | m5.large |
| c5.2xlarge | c5.xlarge |
| c5.xlarge | c5.large |
| t3.large | t3.medium |

- `DoNotResize=true` 태그가 있는 서버는 제외 (라이선스가 CPU 수에 묶여 있음)
- 타입 변경은 **중지 → 변경 → 시작**. 작업 후 모든 서버는 다시 **실행 중**이어야 함
MD
give "$H/rightsizing.md"
