#!/bin/bash
# This script is used to get the images from the phone into the remnote folder
# it also moves the transferred images from the downloads folder to the scans folder remotely


scp -r phspot:downloads/* ~/Pictures/Remnote

ssh phspot << 'EOF'
if [[ ! -d scans ]]; then
    mkdir scans
fi

mv downloads/* scans

if [[ $? -ne 0 ]]; then
    echo "No file in the 'downloads' folder!"
fi
EOF
