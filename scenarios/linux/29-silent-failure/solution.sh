sed -i '1a set -euo pipefail' ~/deploy.sh
sed -i 's#^ARTIFACT=~/build/app-\$VERSION.tar.gz#ARTIFACT=~/build/app-v$VERSION.tar.gz#' ~/deploy.sh
~/deploy.sh 2.5.0
