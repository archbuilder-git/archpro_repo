#!/bin/bash

# Clean old repo files
rm -f archpro-repo*

echo "repo-add"
repo-add -s -n -R archpro-repo.db.tar.gz *.pkg.tar.zst || { echo "repo-add failed!"; exit 1; }

sleep 1

# Clean any old leftover extracted db/files
rm -f archpro-repo.db
rm -f archpro-repo.files

# Rename the new database and file list to the expected format
mv archpro-repo.db.tar.gz archpro-repo.db
mv archpro-repo.files.tar.gz archpro-repo.files

# Rename and preserve signature files for metadata
mv archpro-repo.db.tar.gz.sig archpro-repo.db.sig 2>/dev/null
mv archpro-repo.files.tar.gz.sig archpro-repo.files.sig 2>/dev/null

# Export public key for users to import
gpg --armor --export DFB61E9697C6C104 > archpro.gpg

echo "####################################"
echo "Repo Updated!!"
echo "####################################"
