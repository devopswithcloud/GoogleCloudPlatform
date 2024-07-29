#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Startup Scripts</title>
</head>
<body>
<h1> Startup Scripts </h1>
<p>This is coming from VM </p1>
</body>
</html>
EOF
