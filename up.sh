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

# Explicitly add all necessary repository files, including signature files
git add --all .
git add x86_64/archpro_repo.db x86_64/archpro_repo.db.sig
git add x86_64/archpro_repo.files x86_64/archpro_repo.files.sig

# Check if there are any changes before committing
if git diff --staged --quiet; then
    echo "No changes to commit."
else
    # Commit and push only if there are actual changes
    git commit -m "Auto-update repository database and signatures"
    git push -u origin main || { echo "Git push failed!"; exit 1; }
fi

echo "################################################################"
echo "###################    Git Push Done      ######################"
echo "################################################################"
