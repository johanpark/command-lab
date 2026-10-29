#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
G=/app/payment-api
aws logs create-log-group --log-group-name "$G"
aws logs create-log-group --log-group-name /app/batch
aws logs create-log-group --log-group-name /app/web
streams=(); for i in 1 2 3 4; do streams+=("i-0$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n' | cut -c1-16)"); done
bad=${streams[$(rand_int 0 3)]}
secret_set bad "$bad"
now=$(date +%s)000
python3 - "$now" "$bad" "${streams[@]}" > /opt/cmdlab/secret/events.json <<'PY'
import json, random, sys
now = int(sys.argv[1]); bad = sys.argv[2]; streams = sys.argv[3:]
rnd = random.Random()
out = {s: [] for s in streams}
oom = 0
for s in streams:
    t = now - 2 * 3600 * 1000
    for _ in range(rnd.randint(80, 120)):
        t += rnd.randint(20, 90) * 1000
        r = rnd.random()
        if r < 0.05:
            msg = f"ERROR PaymentService - card declined (code=51) order={rnd.randint(10000, 99999)}"
        elif r < 0.15:
            msg = f"WARN  PaymentService - slow PG response {rnd.randint(1500, 4000)}ms"
        else:
            msg = f"INFO  PaymentService - paid order={rnd.randint(10000, 99999)} {rnd.randint(30, 300)}ms"
        out[s].append({"timestamp": t, "message": msg})
    if s == bad:
        for _ in range(rnd.randint(6, 12)):
            out[s].append({"timestamp": rnd.randint(now - 3600 * 1000, now - 60000),
                           "message": "ERROR java.lang.OutOfMemoryError: Java heap space at PaymentService.batchSettle"})
            oom += 1
for s in out:
    out[s].sort(key=lambda e: e["timestamp"])
print(json.dumps({"streams": out, "oom": oom}))
PY
for s in "${streams[@]}"; do
  aws logs create-log-stream --log-group-name "$G" --log-stream-name "$s"
  jq -c --arg s "$s" '.streams[$s]' /opt/cmdlab/secret/events.json > /tmp/ev.json
  aws logs put-log-events --log-group-name "$G" --log-stream-name "$s" --log-events file:///tmp/ev.json >/dev/null
done
jq -r .oom /opt/cmdlab/secret/events.json > /opt/cmdlab/secret/oom
# 다른 서비스에도 OutOfMemoryError (세면 안 됨)
aws logs create-log-stream --log-group-name /app/batch --log-stream-name i-0batch0001
aws logs put-log-events --log-group-name /app/batch --log-stream-name i-0batch0001 --log-events \
  "timestamp=$((${now%000} - 600))000,message=ERROR java.lang.OutOfMemoryError: GC overhead limit exceeded" \
  "timestamp=$((${now%000} - 300))000,message=ERROR java.lang.OutOfMemoryError: Java heap space" >/dev/null
rm -f /tmp/ev.json
