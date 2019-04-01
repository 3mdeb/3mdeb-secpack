#!/bin/bash

function usage {
    echo -e "Usage:"
    echo -e "$0 FILE KEY_ID ID_SUFFIX"
    echo -e "\tFILE - file name and path to be signed"
    echo -e "\tKEY_ID - short key fingerprint to be used by GPG"
    echo -e "\tID_SUFFIX - ID suffix of the signer appended to .sig file name"
    echo -e "If no KEY_ID and ID_SUFFIX provided, script performs quick signing"
    echo -e "with Michał Żygowski and Piotr Król keys"
    exit 1
}

if [ $# -le 0 ]; then
    usage
fi

file=$(basename "$1") 
key=$2
suffix=$3

if [ ! -n "$suffix" && ! -n "$key" ]; then
	if [ -f "$file" ]; then
		gpg --default-key D21FCEB2 --armor --output $file.sig.miczyg --sign --detach-sign $file
		gpg --verify $file.sig.miczyg $file
		gpg --default-key 67AA9E4C --armor --output $file.sig.piotr-krol --sign --detach-sign $file
		gpg --verify $file.sig.piotr-krol $file
	else
		echo "$file not found."
		exit 1
	fi
else
	if [ -f "$file" ]; then
		gpg --default-key $key --armor --output $file.sig.$suffix --sign --detach-sign $file
		gpg --verify $file.sig.$suffix $file
	else
		echo "$file not found."
		exit 1
	fi
fi



