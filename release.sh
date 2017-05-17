#!/bin/bash

v=$(date +%y%M.%d%H)
echo $v > ver

sed -i -e 's/^VERSION = .*:VERSION:/VERSION = "'$v'" #:VERSION:/' vpnstart 

git add ver vpnstart
git commit -m 'release'

echo "You should push origin"
