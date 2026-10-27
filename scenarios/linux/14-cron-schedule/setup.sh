#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/scripts"
for s in backup report health; do
  printf '#!/usr/bin/env bash\necho "[%s] $(date)" >> "$HOME/scripts/cron.log"\n' "$s" > "$H/scripts/$s.sh"
  chmod 755 "$H/scripts/$s.sh"
done
give "$H/scripts"
crontab -u "$LEARNER" -r 2>/dev/null || true
