#!/bin/bash -ex

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo "Deploying..."
ant deployCode -Dsfdc.username=$SF_USERNAME -Dsfdc.password=$SF_PASSWORD -Dsfdc.serverurl=$SF_SERVER_URL


