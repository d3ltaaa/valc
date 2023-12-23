#!/bin/bash

echo "Fast Git commit!"
read -p "Give the commit a name!: " name
sleep 1
git add *
git commit -m "$name"
git push origin main
