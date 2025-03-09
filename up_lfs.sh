#!/bin/bash
#set -e

#echo "# archpro-repo" >> README.md
#git init
git lfs install
git lfs track '*.pkg.tar.zst'
git add .gitattributes
#git add README.md
#git commit -m "first commit"
#git branch -M main
#git remote add origin https://github.com/archbuilder-iso/archpro-repo.git
#git push -u origin main

cd x86_64
sh ./update_repo.sh
cd ..
# checking if I have the latest files from github
#echo "Checking for newer files online first"
git pull


# Below command will backup everything inside the project folder
git add --all .

# Give a comment to the commit if you want
echo "####################################"
echo "Write your commit comment!"
echo "####################################"

read input

# Committing to the local repository with a message containing the time details and commit text

git commit -m "$input"


# Push the local files to github
git push -u origin main


echo "################################################################"
echo "###################    Git Push Done      ######################"
echo "################################################################"
