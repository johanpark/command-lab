#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
ver="deploytool v$(rand_int 1 3).$(rand_int 0 9).$(rand_int 0 20)"
secret_set ver "$ver"
mkdir -p "$H/tools/bin"
cat > "$H/tools/bin/deploytool" <<SCRIPT
#!/usr/bin/env bash
case "\$1" in
  --version) echo "$ver" ;;
  *) echo "사용법: deploytool --version | deploy <환경>" ;;
esac
SCRIPT
chmod 755 "$H/tools/bin/deploytool"
give "$H/tools"
