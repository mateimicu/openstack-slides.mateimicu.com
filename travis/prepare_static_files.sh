#!/usr/bin/env bash
echo "Deleting old publication"

CNAME="openstack-slides.micumatei.com"

echo "get the themes"
git submodule update

rm -rf public

echo "Generating site"
/tmp/hugo

echo "Save the static files."
cp -r public /tmp/hugo-public

echo "Clean directory"
rm -rf *

echo "Copy the static files"
cp -r /tmp/hugo-public/* .

echo "Add CNAME reference for gh-pages"
echo "$CNAME" >> CNAME
