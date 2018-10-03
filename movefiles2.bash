#!/bin/bash -e

files=files.diff
PRNUMBER=208
USERNAME=pedro.fartaria@b-i.com
PASSWORD=SalesforceRules!!!

# get full diff information
#curl https://bitbucket.org/api/2.0/repositories/iatasfdc/tip/pullrequests/$PRNUMBER/diff -L -o $files -u $USERNAME:$PASSWORD

# find lines starting with +++
# find lines for files +++ b/src/...
# remove metadata lines (we will need all, not just the changed ones)
# remove trailing characters
# sort lines
# make sure we have no duplicates
# Escape spaces on the layouts
# remove trailing whitespaces
##results=$(grep '^+++' $files | grep '/src/' | grep -v '.xml' | sed 's/+++ b\///' | sort | uniq | sed 's/ /\\ /g' | sed 's/[ \t]*$//' )

# replace file with results
#export IFS="
#"
#for line in $results; do
 #   echo $line  
#done > $files

#echo "done"

# fetch files on the src folder and copy them to Code, so we can deploy
while IFS="
" read p;
do
  folder=$(echo $(dirname "${p}")| cut -d'/' -f 2-)
  filename=$(echo $p| cut -d'/' -f 3-)
  mkdir -p Code/$folder
  echo -e "\nMoving $filename to folder $folder"
  cp "$p" Code/$folder
  if [ -f "${p}-meta.xml" ]; then
    echo -e "Moving ${filename}-meta.xml to folder $folder"
    cp "${p}-meta.xml" Code/$folder
  fi
done <$files

#to do create package xml
echo "done"