#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
J="$H/jobs"; rm -rf "$J" "$H/daily-reports"; mkdir -p "$J/tmp"
keep=$(rand_int 5 9)
echo "{\"tmp_dir\": \"/home/learner/jobs/tmp\", \"keep_days\": $keep}" > "$J/config.json"
cat > "$J/cleanup.py" <<'PY'
#!/usr/bin/env python3
"""tmp 폴더에서 keep_days 일보다 오래된 파일을 지운다."""
import json
import time
from pathlib import Path

with open("config.json") as f:
    config = json.load(f)

limit = time.time() - config["keep_days"] * 86400
removed = 0
for p in Path(config["tmp_dir"]).glob("*"):
    if p.is_file() and p.stat().st_mtime < limit:
        p.unlink()
        removed += 1
print(f"[cleanup] {time.strftime('%F %T')} {config['keep_days']}일 지난 파일 {removed}개 삭제")
PY
cat > "$J/daily_report.js" <<'JS'
#!/usr/bin/env node
// 일일 보고서를 $REPORT_DIR/날짜.txt 로 만든다.
const fs = require('fs');
const path = require('path');

const dir = process.env.REPORT_DIR;
if (!dir) {
  console.error('[report] REPORT_DIR 가 설정되지 않았습니다');
  process.exit(1);
}
const today = new Date().toISOString().slice(0, 10);
const tmpCount = fs.readdirSync(path.join(__dirname, 'tmp')).length;
fs.mkdirSync(dir, { recursive: true });
const file = path.join(dir, `${today}.txt`);
fs.writeFileSync(file, `일일 보고서 ${today}\n임시 파일 ${tmpCount}개\n`);
console.log(`[report] ${file} 작성`);
JS
chmod +x "$J/cleanup.py" "$J/daily_report.js"
grep -q REPORT_DIR "$H/.bashrc" || printf '\n# 보고서 저장 위치\nexport REPORT_DIR=$HOME/daily-reports\n' >> "$H/.bashrc"
give "$J" "$H/.bashrc"
crontab -u "$LEARNER" -r 2>/dev/null || true
