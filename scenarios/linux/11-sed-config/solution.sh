grep -rl --include=config.ini old-db ~/services | xargs sed -i 's/old-db\.internal/new-db.internal/g'
grep -rlE --include=config.ini '^debug *= *true' ~/services | xargs sed -i 's/^debug *= *true$/debug = false/'
