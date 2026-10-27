find ~/app-config -type f -name '*.conf' -mtime -1 > ~/changed.txt
find ~/app-config -type f -empty -delete
