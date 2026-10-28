tar tzf ~/downloads/app-2.4.0.tar.gz | head -n 3
tar tzf ~/downloads/plugins.tar.gz | head -n 3
mkdir -p /srv/app/releases/2.4.0/plugins
tar xzf ~/downloads/app-2.4.0.tar.gz -C /srv/app/releases/2.4.0 --strip-components=1
tar xzf ~/downloads/plugins.tar.gz -C /srv/app/releases/2.4.0/plugins
ls -l /srv/app/releases/2.4.0/bin
