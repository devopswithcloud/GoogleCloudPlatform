#! /bin/bash
sudo apt update -y
sudo apt install apache2 git -y
sudo rm -rf /var/www/html/index.html
sudo git clone https://github.com/devopswithcloud/static-website.git
sudo cp -r static-website/* /var/www/html