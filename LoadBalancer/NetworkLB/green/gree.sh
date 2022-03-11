#! /bin/bash
sudo apt-get update
sudo apt-get install apache2 wget -y
cd /var/www/html
rm -rf index.html
wget https://raw.githubusercontent.com/devopswithcloud/GoogleCloudPlatform/master/LoadBalancer/NetworkLB/green/index.html
sudo service apache2 restart