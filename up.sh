#!/bin/bash
#set -e

cd x86_64
sh ./update_repo.sh || { echo "Repository update failed!"; exit 1; }
cd ..

# Stash any uncommitted changes before pulling
git stash --include-untracked

# Ensure the latest changes are pulled with rebase
git pull --rebase

# Restore stashed changes (if any)
git stash pop || echo "No stashed changes to restore."

# Ensure remote is set up correctly
if ! git remote | grep -q origin; then
    git remote add origin git@github.com:archbuilder-git/archpro_repo.git
fi

# Explicitly add repository database and signature files
git add x86_64/archpro_repo.db x86_64/archpro_repo.db.sig
git add x86_64/archpro_repo.files x86_64/archpro_repo.files.sig

# Also add any new packages
git add --all .

# Commit message prompt
echo "####################################"
echo "Write your commit comment!"
echo "####################################"

read input

# Commit only if there are changes
if git diff --staged --quiet; then
    echo "No changes to commit."
else
    git commit -m "$input"
    # Push to GitHub
    git push -u origin main || { echo "Git push failed!"; exit 1; }
fi

echo "################################################################"
echo "###################    Git Push Done      ######################"
echo "################################################################"
