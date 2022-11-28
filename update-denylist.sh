#!/bin/bash

folder="./denylist"
custom="./customdeny.txt"

rm -rf $folder

mkdir $folder
for i in {0..255}; do mkdir $folder/$(printf "%02x" $i); done

{ curl -sN https://badbits.dwebops.pub/denylist.json | jq -r '.[].anchor' ; cat $custom 2>/dev/null ; } | while read -r line; do echo "$line" >> $folder/${line:0:2}/${line:0:4}; done

echo "denylist updated"
