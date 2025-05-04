#!/bin/bash

# Clean old repo files
rm -f archpro_repo*

echo "repo-add"
repo-add -s -n -R archpro_repo.db.tar.gz *.pkg.tar.zst || { echo "repo-add failed!"; exit 1; }

sleep 1

# Clean any old leftover extracted db/files
rm -f archpro_repo.db
rm -f archpro_repo.files

# Rename the new database and file list to the expected format
mv archpro_repo.db.tar.gz archpro_repo.db
mv archpro_repo.files.tar.gz archpro_repo.files

# Rename and preserve signature files for metadata
mv archpro_repo.db.tar.gz.sig archpro_repo.db.sig 2>/dev/null
mv archpro_repo.files.tar.gz.sig archpro_repo.files.sig 2>/dev/null

# Export public key for users to import
gpg --armor --export DFB61E9697C6C104 > archpro.gpg

echo "####################################"
echo "Repo Updated!!"
echo "####################################"
