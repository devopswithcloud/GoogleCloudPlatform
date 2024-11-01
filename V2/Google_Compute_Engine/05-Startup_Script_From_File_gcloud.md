
# Guide: Passing a Startup Script as a File in Google Cloud with gcloud Command

This guide demonstrates how to pass a VM-level startup script as a file using the `gcloud` command. This script will override any project-level metadata startup script.

---

### Step 1: Create the Updated Startup Script

Save the following content in a file called `startup-script.sh`:

```bash
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=$(hostname)
sudo echo "<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            background-color: #004d40;
            color: #ffffff;
            font-family: 'Arial', sans-serif;
            text-align: center;
            padding: 50px;
            margin: 0;
        }
        h1 { color: #ffab00; font-size: 2.5em; margin-bottom: 20px; }
        p { font-size: 1.2em; margin: 10px 0; }
        .hostname { color: #ffccbc; }
        .ip-address { color: #80deea; }
        .version { color: #ff5722; font-weight: bold; font-size: 1.5em; margin-top: 30px; }
        strong { color: #e0f2f1; }
    </style>
</head>
<body>
    <h1>i27academy Google Cloud Platform - StartupScript passed as script from gcloud</h1>
    <p><strong class='hostname'>Server Hostname:</strong> ${HOSTNAME}</p>
    <p><strong class='ip-address'>Server IP Address:</strong> $(hostname -I)</p>
    <p class='version'>Custom Script Version</p>
</body>
</html>" | sudo tee /var/www/html/index.html
```

This HTML includes `<h1>` with **"StartupScript passed as script from gcloud"**, and a version line with **"Custom Script Version"**.

---

### Step 2: Use the gcloud Command

Run this `gcloud` command to create the VM and pass the `startup-script.sh` file as the startup script:

```bash
gcloud compute instances create startup-script-from-file     --zone=us-central1-a     --machine-type=e2-micro     --tags=http-server     --metadata-from-file startup-script=startup-script.sh
```

This command creates a VM named `startup-script-from-file` in the `us-central1-a` zone and applies the `startup-script.sh` script, overriding any project-level startup metadata.

---