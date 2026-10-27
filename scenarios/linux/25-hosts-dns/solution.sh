getent hosts api.internal | awk '{print $1}' > ~/answer.txt
sed 's/^.*api\.internal$/127.0.0.1  api.internal/' /etc/hosts > /tmp/hosts.new
sudo tee /etc/hosts < /tmp/hosts.new > /dev/null
