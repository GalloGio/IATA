#!/bin/bash -ex
serverurl=https://test.salesforce.com

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo "Deploying..."
ant validateCodeLocal -Dsfdc.username=$username -Dsfdc.password=$password -Dsfdc.serverurl=$serverurl


