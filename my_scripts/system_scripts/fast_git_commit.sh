#!/bin/bash

if [[ "$(git status --porcelain)" != "" ]]; then
	echo "Fast Git commit!"
	read -p "Give the commit a name!: " name
	sleep 1
	firefox about:logins#%7B02b405cb-aa1e-404a-8d0f-9f45e2f2351a%7D &
	git add *
	git commit -m "$name"
	git push origin main
fi
