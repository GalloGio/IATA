#!/bin/bash -ex

# Enter Build folder
cd build

# Perform the actual deployment on related repository environment
echo "Deploying..."
ant deployCode -Dsfdc.username=macaricol@iata.org.ngr1trials -Dsfdc.password=Dots0Lines -Dsfdc.serverurl=$SF_SERVER_URL 


