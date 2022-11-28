#!/bin/bash

folder="/usr/share/ipfs-denylist/denylist"

rm -rf $folder

mkdir $folder
for i in {0..255}; do mkdir $folder/$(printf "%02x" $i); done

curl -sN https://badbits.dwebops.pub/denylist.json | jq -r '.[].anchor' | while read -r line; do echo "$line" >> $folder/${line:0:2}/${line:0:4}; done

echo "denylist updated"
