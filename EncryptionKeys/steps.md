### Below are the steps to execute the ENcryption Module

```bash
python3 generate-csek.py
gsutil -o 'GSUtil:encryption_key='n4sUxnFqz3oHbkfdfdfds5WH+RONyyUYfNX1Vdw9kZtvVm+heM50= cp csek.txt gs://$DEVSHELL_PROJECT_ID-csek/csek.txt
gsutil -o 'GSUtil:decryption_key1='encryptionkey cat gs://$DEVSHELL_PROJECT_ID-csek/csek.txt
gsutil config -n # this file creates a .boto file ar the ~ 
```
