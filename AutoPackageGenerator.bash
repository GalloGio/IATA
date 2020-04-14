
#
#  AutoPackageGenerator
#  requires configPackageGenerator.config to work
#
#     Based on an id of a pull request, copies the edited files to Code folder
#   and generates the package.xml file at the end. 
#     The scipt can be disable in the configPackageGenerator the copy of the files
#   or the generation of the package.xml file.
#     The script automatically maps the folder name to the respective Metadata name.
#   This map is accomplish with the help of the 'mapFolderMetadata' map.
#     The script also copies the xml files for the classes or triggers but ignores 
#   to add thoose in the package.xml file.
#
#   BE AWARE THAT FOR SOME FILES (LIKE EMAILS OR DASHBOARDS) IT MIGHT BE CREATED 
#   NEW FOLDERS TO ACCOMMODATE THIS FILES.
#   TO ENSURE THAT THE FOLDER IS CREATED WITH ANT, IT'S REQUIRED THE XML IN THE package.XML
#
#     For this situations, it's possible to specify in the configPackageGenerator, in the
#   'FOLDER_LIST' the list of folders that can have other folders.
#
#  Made by Diogo Alves
#    based on original moveFiles.bash
#


createBuildFile(){

	printf "\n ## Starting to create package.xml ##\n\n"


	IFS=$'\n'; set -f
	sorted_keys=($(
	    for key in "${!resultsMap[@]}"; do
	      printf '%s:%s\n' "$key" "${resultsMap[$key]}"
	    done | sort -t : -k 2n | sed 's/:.*//'))
	unset IFS; set +f

	printf "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" > package.xml
	printf "<Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">\n" >> package.xml

	#	toSort=("ApexPage"
	#		"ApexClass"
	#	)
	#echo "inicio" $toSort
	#IFS=$'\n' sorted=($(sort <<<"${toSort[*]}"))
	#echo "fim: " $sorted
	
	#for i in "${sorted[@]}"
	#for i in ${sorted[*]}

	for i in "${sorted_keys[@]}"
	do   
		printf "    <types>\n" >> package.xml
	#  echo "key  : $i"
	  value=${resultsMap[$i]}
	  printf "\n\n type: $i\n"
	  #echo "\n\n\nvalues before cast: ${value}"

	  line=(${resultsMap[$i]})
	  #iteratedValue=(`echo ${line}`);

	  #declare -n iteratedValue=line
	  IFS=' ' read -a iteratedValue <<< "$value"
	  #iteratedValue=$(echo ${value})

	  #echo "\nvalues after cast: $line\n\n"

	  	IFS=$'\n'; set -f
		sorted_keys2=($(
		    for key in "${iteratedValue[@]}"; do
		      printf '%s:%s\n' "$key" "${resultsMap[$key]}"
		    done | sort -t : -k 2n | sed 's/:.*//'))
		unset IFS; set +f


	  for ii in "${sorted_keys2[@]}"
	  do
	    #fileName=${iteratedValue[$ii]}
	    #echo "#filename: $filename}"
	    fileName=$ii
	    base=${ii%.*}
	    base="${base//#/ }"
	  	printf "file: $ii. Saved as $base\n"
	    #base="${base:1}"

	    #base=${ii%.*}
	    #echo "#final: $base}"
		##if [[ -z "$PRNUMBER" ]]; then
		if [ $base == "CustomLabels" ]; ##add * for labels
		then 
			printf "        <members>*</members>\n" >> package.xml
		else
		printf "        <members>$base</members>\n" >> package.xml
		fi
	  done 

		printf "        <name>$i</name>\n" >> package.xml
		printf "    </types>\n" >> package.xml

	done 

	printf "    <version>$API_VERSION</version>\n" >> package.xml
	printf "</Package>" >> package.xml
	mv package.xml Code/
	printf "\n  DONE\n\n"
}

source AutoPackageGenerator.config
declare -A resultsMap


declare -A toAppend
lastType="-1"


printf "  ___        _       ______          _                    _____                           _             
 / _ \      | |      | ___ \        | |                  |  __ \                         | |            
/ /_\ \_   _| |_ ___ | |_/ /_ _  ___| | ____ _  __ _  ___| |  \/ ___ _ __   ___ _ __ __ _| |_ ___  _ __ 
|  _  | | | | __/ _ \|  __/ _\` |/ __| |/ / _\` |/ _\` |/ _ \ | __ / _ \ \'_ \ / _ \ \'__/ _\` | __/ _ \| \'__|
| | | | |_| | || (_) | | | (_| | (__|   < (_| | (_| |  __/ |_\ \  __/ | | |  __/ | | (_| | || (_) | |   
\_| |_/\__,_|\__\___/\_|  \__,_|\___|_|\_\__,_|\__, |\___|\____/\___|_| |_|\___|_|  \__,_|\__\___/|_|   
                                                __/ |                                                   
                                               |___/     "


printf "\n\n\n"

if [[ -z "$PRNUMBER" ]]; then
	printf "Pull request number not setted in configPackageGenerator.config.\nInsert the PR number [ENTER]: "
	read PRNUMBER
fi

if [[ -z "$BITBUCKET_USERNAME" ]]; then
	printf "\n\nBitbucket username not setted in configPackageGenerator.config.\nInsert the username [ENTER]: "
	read BITBUCKET_USERNAME
fi

if [[ -z "$BITBUCKET_PASSWORD" ]]; then
	printf "\n\nBitbucket password not setted in configPackageGenerator.config.\nInsert the password [ENTER]: "
	read -s BITBUCKET_PASSWORD
fi

if [[ -z "$REMOVE_TEMP" ]]; then
	printf "\n\nREMOVE_TEMP not setted in configPackageGenerator.config.\nDo you want to remove the temporary file? (Y/N) [ENTER]: "
	while true; do
	read REMOVE_TEMP
    case $REMOVE_TEMP in
        [Yy]* ) echo "yes"; REMOVE_TEMP=true; break;;
        [Nn]* ) echo "no"; REMOVE_TEMP=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi

if [[ -z "$COPY_FILES" ]]; then
	printf "\n\nCOPY_FILES not setted in configPackageGenerator.config.\nDo you want to copy the PR files to Code folder? (Y/N) [ENTER]: "
	while true; do
	read COPY_FILES
    case $COPY_FILES in
        [Yy]* ) echo "yes"; COPY_FILES=true; break;;
        [Nn]* ) echo "no"; COPY_FILES=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi

if [[ -z "$GENERATE_PACKAGE_FILE" ]]; then
	printf "\n\nGENERATE_PACKAGE_FILE not setted in configPackageGenerator.config.\nDo you want to generate the package.xml file? (Y/N) [ENTER]: "
	while true; do
	read GENERATE_PACKAGE_FILE
    case $GENERATE_PACKAGE_FILE in
        [Yy]* ) echo "yes"; GENERATE_PACKAGE_FILE=true; break;;
        [Nn]* ) echo "no"; GENERATE_PACKAGE_FILE=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi

# get full diff information
curl https://bitbucket.org/api/2.0/repositories/$PROJECT/$REPOSITORY/pullrequests/$PRNUMBER/diff -L -o $files -u $BITBUCKET_USERNAME:$BITBUCKET_PASSWORD

# find lines starting with +++
# find lines for files +++ b/src/...
# remove metadata lines (we will need all, not just the changed ones)
# remove trailing characters
# sort lines
# make sure we have no duplicates
# Escape spaces on the layouts
# remove trailing whitespaces
#echo "##" $files
results=$(grep '^+++' $files | grep '/src/' | grep -v '.xml' | sed 's/+++ b\///' | sort | uniq | sed 's/ /\\ /g' | sed 's/[ \t]*$//' )
#echo "##" $results
# replace file with results
export IFS="
"
for line in $results; do
    echo $line  
done > $files

printf "\nDONE\n\n All data fetch from the pull request. Starting the hard work!"
printf "\n----------------------------------------------------------------------\n\n"

# fetch files on the src folder and copy them to Code, so we can deploy

printf "\n ## Copy all files to Code folder and store in a MAP to later generate package.xml ##\n\n"

declare -A toAppend
position=0
lastType="-1"
while IFS="
" read p; #p fileName
do
  folder=$(echo $(dirname "${p}")| cut -d'/' -f 2-)
  filename=$(echo $p| cut -d'/' -f 3-)
  firstFolder=$(echo "$folder" | cut -d "/" -f1)

  #Store in map to later generate package.xml
  if "$GENERATE_PACKAGE_FILE" ; then
	  if [[ $firstFolder != $lastType ]]; then
	  	printf "\n\n - files in folder: $firstFolder will be stored with metadata: ${mapFolderMetadata[$firstFolder]}"

	  	##if folder lwc or aura retrieve all the folder
	  	
		if [[ "-1" != $lastType ]]; then
	  	folderMetadataName=${mapFolderMetadata[$lastType]}
	    resultsMap[$folderMetadataName]="${toAppend[@]}"
	    #echo ${toAppend[@]}
	  	#echo "previous files save with $folderMetadataName" 
	  fi
	    unset toAppend
	    declare -A toAppend
		  lastType=$firstFolder
		  position=0
		fi

		if [[ $filename != *$EXTENSION_TO_COMPARE* ]]; then
		  toAppend[$position]="${filename// /#}"
		  position=$((position + 1))
		fi
		
		if [[ $filename == *$EXTENSION_TO_COMPARE* ]]; then
			if echo $FOLDER_LIST | grep -w $firstFolder > /dev/null; then
				finalName=${filename%"$EXTENSION_TO_COMPARE"}
				printf "\nnew folder in $firstFolder: $filename. save with: ${finalName}\n\n"
		  		toAppend[$position]="${finalName// /#}"
		  		position=$((position + 1))
			fi
		fi
	fi
    #done store
	

  #copy files to Code folder
  
  if "$COPY_FILES" ; then
	  mkdir -p Code/$folder
	  echo -e "\n    Moving $filename to folder $folder"
	  cp "$p" Code/$folder
	  if [ -f "${p}-meta.xml" ]; then
	    echo -e "    Moving ${filename}-meta.xml to folder $folder"
	    cp "${p}-meta.xml" Code/$folder
	  fi
  fi
  #done copy		

done <$files

folderMetadataName=${mapFolderMetadata[$lastType]}
resultsMap[$folderMetadataName]="${toAppend[@]}"

printf "\n  DONE\n\n"

createBuildFile

if "$REMOVE_TEMP" ; then
	printf "\n ## Removing temporary file (can be turned off in config) ##\n\n "
	rm $files
	printf "\n  DONE\n\n"
fi

printf "\n     All DONE!\n     cheers!\n\n"

