cd ~
tail -n 5 ~/app/logs/app.log
sudo chown learner:learner ~/app/config/app.env
sed -i 's/^PORT=.*/PORT=9000/; s#/publc$#/public#' ~/app/config/app.env
./deploy.sh
