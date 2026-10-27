cd ~/app
ln -sfn releases/2.3.1 current
./restart.sh
diff -r releases/2.3.1 releases/2.4.0 | grep '^Only in releases/2.3.1' | awk '{print $NF}' > ~/answer.txt
