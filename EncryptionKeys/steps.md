### Below are the steps to execute the ENcryption Module

```bash
python3 generate-csek.py
gsutil -o 'GSUtil:encryption_key='YOUR_OWN_ENCRYPTION_KEY cp csek.txt gs://$DEVSHELL_PROJECT_ID-csek/csek.txt
gsutil -o 'GSUtil:decryption_key1='YOUR_OWN_ENCRYPTION_KEY cat gs://$DEVSHELL_PROJECT_ID-csek/csek.txt
gsutil config -n # this file creates a .boto file ar the ~ 
```
