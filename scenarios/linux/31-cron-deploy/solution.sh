sed -i 's|^set -e$|set -e\ncd "$(dirname "$0")"\nexport PATH="$HOME/.local/bin:$PATH"|' ~/deploy/nightly.sh
cd / && env -i HOME=$HOME PATH=/usr/bin:/bin bash ~/deploy/nightly.sh
