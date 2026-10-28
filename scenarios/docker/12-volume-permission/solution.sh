docker exec uploader id
sudo chown -R 1000:1000 /srv/uploads
sleep 4
docker logs --tail 2 uploader
