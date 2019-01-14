# set the origin remote to our developer sandbox

cd build

ant getCodePointAndClick -Dsfdc.username=$SF_USERNAME -Dsfdc.password=$SF_PASSWORD -Dsfdc.serverurl=$SF_SERVER_URL -Dbasedir=$BITBUCKET_CLONE_DIR

cd ..

var=$(pwd)
echo "The current working directory $var."

git remote rm origin
git remote add origin https://$GIT_USERNAME:$GIT_PASSWORD@bitbucket.org/iatasfdc/$GIT_REPONAME.git

git clone https://$GIT_USERNAME:$GIT_PASSWORD@bitbucket.org/iatasfdc/$GIT_REPONAME.git 

git checkout master

git config user.name $GIT_USERNAME
git config user.email $GIT_USERNAME@iata.org
# add, commit and push changes
filelist=`git status -s`
if [[ -n $filelist ]]; then
  	git add src/*
  	git commit -a -m " AUTOMATIC COMMIT by $GIT_USERNAME"
 	returnval=`git push -f origin master`
 	if [[ -z $returnval ]]; then 
 		echo $returnval+"mmm"
 		exit 0;
 	else
 		exit 1;
 	fi
else 
	echo '**** Nothing to commit ****'
	exit 1
fi    