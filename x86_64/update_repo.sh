#!/bin/bash

rm archpro-repo*

echo "repo-add"
repo-add -s -n -R archpro-repo.db.tar.gz *.pkg.tar.zst

sleep 1

rm archpro-repo.db
rm archpro-repo.db.sig

rm archpro-repo.files
rm archpro-repo.files.sig

mv archpro-repo.db.tar.gz archpro-repo.db
#mv archpro-repo.db.tar.gz.sig archpro-repo.db.sig

mv archpro-repo.files.tar.gz archpro-repo.files
#mv archpro-repo.files.tar.gz.sig archpro-repo.files.sig


echo "####################################"
echo "Repo Updated!!"
echo "####################################"
