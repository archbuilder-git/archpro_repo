#!/bin/bash

rm archpro_repo*

echo "repo-add"
repo-add -s -n -R archpro_repo.db.tar.gz *.pkg.tar.zst

sleep 1

rm archpro_repo.db
rm archpro_repo.db.sig

rm archpro_repo.files
rm archpro_repo.files.sig

mv archpro_repo.db.tar.gz archpro_repo.db
mv archpro_repo.files.tar.gz archpro_repo.files


echo "####################################"
echo "Repo Updated!!"
echo "####################################"
