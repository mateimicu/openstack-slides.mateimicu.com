#!/usr/bin/env bash
# Clone the Hugo binary

pushd /tmp

wget "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz"
tar -zxvf "/tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz"
cp "/tmp/hugo_${HUGO_VERSION}_Linux-64bit/hugo" "/tmp/hugo"
popd
