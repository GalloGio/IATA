#!/bin/bash -ex

#set standard variables
com=Everything
# username=depu.pedrofartaria@iata.org.tippfdev
# password=User123456
username=deployment.user@iata.org.tipint2
password=User123456789
server=https://test.salesforce.com

#read overrides - ie: deploy.bash -c Layout
while getopts ":c:u:p:e" param; do
  case $param in
    c)
      com=$OPTARG
      ;;
    u)
      username=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    s)
      server=$OPTARG
      ;;
    e)
      #encrypts password
      password=$(echo $(echo $(java -cp ./build/lib/dataloader-29.0.0-uber.jar com.salesforce.dataloader.security.EncryptionUtil -e $password ./build/datascripts/dataloader_encryption_key.txt) | cut -d'-' -f4) | tr -d '[:space:]')
      ;;
  esac
done 

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo -e "========================================================================\n \t\t\t\tStarting deploy \n========================================================================\n\n"
ant deploy$com -Dsfdc.username=$username -Dsfdc.password=$password -Dsfdc.serverurl=$server


