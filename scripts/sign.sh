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

function proof_of_freshness {
	sed -i "s/{date}/$(date -R -u)/g"  $file

	STRING=$(feedstail -1 -n5 -f '{title}' -u https://www.spiegel.de/international/index.rss)
	STRING=`echo ${STRING} | tr '\n' "\\n"` 
	sed -i "s/{freshness1}/$STRING/g"  $file

	STRING=$(feedstail -1 -n5 -f '{title}' -u https://rss.nytimes.com/services/xml/rss/nyt/World.xml)
	STRING=`echo ${STRING} | tr '\n' "\\n"` 
	sed -i "s/{freshness2}/$STRING/g"  $file

	STRING=$(feedstail -1 -n5 -f '{title}' -u https://feeds.bbci.co.uk/news/world/rss.xml)
	STRING=`echo ${STRING} | tr '\n' "\\n"` 
	sed -i "s/{freshness3}/$STRING/g"  $file

	STRING=$(feedstail -1 -n5 -f '{title}' -u http://feeds.reuters.com/reuters/worldnews)
	STRING=`echo ${STRING} | tr '\n' "\\n"` 
	sed -i "s/{freshness4}/$STRING/g"  $file

	sed -i "s/{blockchain_hash}/$(curl -s 'https://blockchain.info/blocks/?format=json' |\
  python3 -c 'import sys, json; print(json.load(sys.stdin)['\''blocks'\''][10]['\''hash'\''])')/g"  $file
}

if [ $# -le 0 ]; then
    usage
fi

file=$(basename "$1") 
key=$2
suffix=$3

if [ ! -n "$suffix" ] && [ ! -n "$key" ]; then
	if [ -f "$file" ]; then
		proof_of_freshness
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
		proof_of_freshness
		gpg --default-key $key --armor --output $file.sig.$suffix --sign --detach-sign $file
		gpg --verify $file.sig.$suffix $file
	else
		echo "$file not found."
		exit 1
	fi
fi



