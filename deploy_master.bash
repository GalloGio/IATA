#!/bin/bash -ex

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo "Deploying..."
ant deployCode -Dsfdc.username=$SUPDEPLOY_USERNAME -Dsfdc.password=$SUPDEPLOY_PASSWORD -Dsfdc.serverurl=$SUPDEPLOY_SERVER_URL 


