#!/bin/bash -ex
username=deploymentuser@iata.org.tipintegr
password=User123456789
serverurl=https://test.salesforce.com

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo "Deploying validateCodeLocal44..."
ant validateCodeLocal -Dsfdc.username=$username -Dsfdc.password=$password -Dsfdc.serverurl=$serverurl


