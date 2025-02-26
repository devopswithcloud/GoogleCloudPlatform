# Create a bucket for CSEK objects
gsutil mb -c regional -l us-central1 gs://$DEVSHELL_PROJECT_ID-csek

# Execute the file to generate the encryption key using the below command
python3 generate-csek.py

# Create a file for testing
vi csek.txt
    * enter some secure text here


# Command used to encryt the object(csek.txt)
gsutil -o 'GSUtil:encryption_key='YOUR_OWN_ENCRYPTION_KEY cp csek.txt gs://$DEVSHELL_PROJECT_ID-csek/csek.txt

# Command used to decrypt the object(csek.txt)
gsutil -o 'GSUtil:decryption_key1='YOUR_OWN_ENCRYPTION_KEY cat gs://$DEVSHELL_PROJECT_ID-csek/csek.txt
 