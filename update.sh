#!/bin/bash

folder="/usr/share/denylist"

rm -rf denylist

mkdir $folder
for i in {0..255}; do mkdir $folder/$(printf "%02x" $i); done

curl -sN https://badbits.dwebops.pub/denylist.json | jq -r '.[].anchor' | while read -r line; do echo "$line" >> denylist/${line:0:2}/${line:0:4}; done

echo "denylist updated"
