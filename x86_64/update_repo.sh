#!/bin/bash

rm archpro_repo*

echo "repo-add"
repo-add -s -n -R archpro_repo.db.tar.gz *.pkg.tar.zst || { echo "repo-add failed!"; exit 1; }

sleep 1

rm archpro_repo.db
rm archpro_repo.files

mv archpro_repo.db.tar.gz archpro_repo.db
mv archpro_repo.files.tar.gz archpro_repo.files

# Preserve and rename the signature files properly
mv archpro_repo.db.tar.gz.sig archpro_repo.db.sig 2>/dev/null
mv archpro_repo.files.tar.gz.sig archpro_repo.files.sig 2>/dev/null

# Export public key for pacman
gpg --armor --export DFB61E9697C6C104 > archpro.gpg

echo "####################################"
echo "Repo Updated!!"
echo "####################################"
