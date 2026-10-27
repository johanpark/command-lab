diff ~/config-old.conf ~/config-new.conf | grep '^<' | cut -d' ' -f2 | sort > /tmp/old-keys
diff ~/config-old.conf ~/config-new.conf | grep '^>' | cut -d' ' -f2 | sort > /tmp/new-keys
comm -12 /tmp/old-keys /tmp/new-keys > ~/changed.txt
comm -23 <(sort -u ~/all-users.txt) <(sort -u ~/active-users.txt) > ~/dormant.txt
