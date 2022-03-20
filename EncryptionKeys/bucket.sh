gsutil mb -c regional -l us-central1 gs://$DEVSHELL_PROJECT_ID-csek
gsutil -o 'GSUtil:encryption_key='$1 cp csek.txt gs://$DEVSHELL_PROJECT_ID-csek
# here $1 indicates, we are sending argument while running the script


#n4sUxnFqz3oHbk5W+RONyyUYNX1Vdw9kZtvVm+heM50=

