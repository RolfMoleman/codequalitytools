#!/bin/bash
## below variables donet work whilst we have the old Azure DevOps url
#SYSTEM_COLLECTIONURI_TRIM=`echo "${SYSTEM_COLLECTIONURI:22}"`
#PROJECT_PATH="$SYSTEM_COLLECTIONURI_TRIM$SYSTEM_TEAMPROJECT/_git/$BUILD_REPOSITORY_NAME"
## old Visual studio permitting variables

if [[ "$SYSTEM_COLLECTIONURI" == *"dev.azure.com"* ]]; then
  echo "Using new URL"
  SYSTEM_COLLECTIONURI_TRIM=`echo "${SYSTEM_COLLECTIONURI:22}"`
  
elif [[ "$SYSTEM_COLLECTIONURI" == *"visualstudio.com"* ]]; then
    echo "Using OLD URL"
    SYSTEM_COLLECTIONURI_TRIM=`echo $SYSTEM_COLLECTIONURI | grep -oP '(?<=//).*(?=.visualstudio.com)'`
    SYSTEM_COLLECTIONURI_TRIM+=/

else
  echo "URL not known"

fi


PROJECT_PATH="$SYSTEM_COLLECTIONURI_TRIM$SYSTEM_TEAMPROJECT/_git/$BUILD_REPOSITORY_NAME"
PROJECT_PATH=`echo "${PROJECT_PATH,,}"`

PROJECT=`echo "${SYSTEM_TEAMPROJECT,,}"`

echo "org: $SYSTEM_COLLECTIONURI_TRIM"
echo "project: $PROJECT"
echo "repo: $BUILD_REPOSITORY_NAME"
echo "path: $PROJECT_PATH"

echo "---[ Preparing for nuget dependabot run ]---"

FILECOUNT="$(find . -name packages.config | wc -l)"
echo "Found $FILECOUNT dependency file(s)."

find . -name packages.config | while read path; do
PARENTNAME="$(basename "$(dirname "$path")")"
DIRECTORY_PATH="/"$PARENTNAME
echo "directory: $DIRECTORY_PATH"
echo "---[ Starting nuget dependabot run: $path ]---"
echo `docker run  -v "$(pwd)/dependabot-script:/home/dependabot/dependabot-script" -w '/home/dependabot/dependabot-script' -e AZURE_ACCESS_TOKEN=$SYSTEM_ACCESSTOKEN -e PACKAGE_MANAGER='nuget' -e PROJECT_PATH=$PROJECT_PATH -e DIRECTORY_PATH=$DIRECTORY_PATH dependabot/dependabot-core:latest bundle exec ruby ./generic-update-script.rb`
echo "---[ Finished nuget dependabot run ]---"
done


echo "---[ Preparing for Maven dependabot run ]---"

FILECOUNT="$(find . -name pom.xml | wc -l)"
echo "Found $FILECOUNT dependency file(s)."

find . -name pom.xml | while read path; do
PARENTNAME="$(basename "$(dirname "$path")")"
DIRECTORY_PATH="/"$PARENTNAME
echo "directory: $DIRECTORY_PATH"
echo "---[ Starting terraform dependabot run: $path ]---"
echo `docker run  -v "$(pwd)/dependabot-script:/home/dependabot/dependabot-script" -w '/home/dependabot/dependabot-script' -e AZURE_ACCESS_TOKEN=$SYSTEM_ACCESSTOKEN -e PACKAGE_MANAGER='maven' -e PROJECT_PATH=$PROJECT_PATH -e DIRECTORY_PATH=$DIRECTORY_PATH dependabot/dependabot-core:latest bundle exec ruby ./generic-update-script.rb`
echo "---[ Finished Maven dependabot run ]---"
done


echo "---[ Preparing for Terraform dependabot run ]---"

FILECOUNT="$(find . -name ptroviders.tf | wc -l)"
echo "Found $FILECOUNT dependency file(s)."

find . -name providers.tf | while read path; do
PARENTNAME="$(basename "$(dirname "$path")")"
DIRECTORY_PATH="/"$PARENTNAME
echo "directory: $DIRECTORY_PATH"
echo "---[ Starting terraform dependabot run: $path ]---"
echo `docker run  -v "$(pwd)/dependabot-script:/home/dependabot/dependabot-script" -w '/home/dependabot/dependabot-script' -e AZURE_ACCESS_TOKEN=$SYSTEM_ACCESSTOKEN -e PACKAGE_MANAGER='terraform' -e PROJECT_PATH=$PROJECT_PATH -e DIRECTORY_PATH=$DIRECTORY_PATH dependabot/dependabot-core:latest bundle exec ruby ./generic-update-script.rb`
echo "---[ Finished Terraform dependabot run ]---"
done

