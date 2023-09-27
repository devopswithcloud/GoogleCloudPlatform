#!/bin/bash

apt update
apt install apache2 -y

# Get project id and assign to variable $PROJECT_ID

# export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

mkdir /var/www/html/images
gsutil -m cp -r gs://omega-vector-398906-images/* /var/www/html/images

# Enable mod_headers.c
sudo a2enmod headers

# Add headers

cat >> /etc/apache2/apache2.conf << EOF

<IfModule mod_headers.c>
    Header set Cache-Control "public, max-age=86400"
</IfModule>
EOF

# Restart Apache service

sudo systemctl restart apache2

cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
    
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>DEMO WEB PAGE</title>
    </head>
    <body>
        
        <h1>Welcome to your i27Academy website using Google Cloud CDN</h1>
        <a href="page-2.html">PAGE 2</a>
        <br>
        <img src='images/icon_cloud.png' width='30%'>
EOF


cat >/var/www/html/page-2.html << EOF
<!DOCTYPE html>
<html>
    
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>DEMO WEB PAGE</title>
    </head>
    <body>
        
        <h1>Page 2 with images</h1>
        <a href="index.html">Back to Home</a>
        <br>
       
        <img src='images/icon_cloud.png' width='30%'>

        <img src='images/basketball.jpg' width='40%'>

        <img src='images/networking-equip.jpg' width='40%'>

        <img src='images/mountains.jpg' width='40%'>
EOF