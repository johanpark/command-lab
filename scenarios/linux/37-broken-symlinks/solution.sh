find ~/site -xtype l | wc -l > ~/answer.txt
ln -sfn /srv/uploads ~/site/releases/v3/uploads
find ~/site -xtype l -delete
