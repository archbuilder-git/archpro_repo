#!/bin/bash

rm archpro_repo*

echo "repo-add"
repo-add -s -n -R archpro_repo.db.tar.gz *.pkg.tar.zst

sleep 1

rm archpro_repo.db
rm archpro_repo.files

mv archpro_repo.db.tar.gz archpro_repo.db
mv archpro_repo.files.tar.gz archpro_repo.files

# Preserve and rename the signature files
mv archpro_repo.db.tar.gz.sig archpro_repo.db.sig 2>/dev/null
mv archpro_repo.files.tar.gz.sig archpro_repo.files.sig 2>/dev/null

echo "####################################"
echo "Repo Updated!!"
echo "####################################"
