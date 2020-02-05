#!/bin/bash

function usage {
    echo -e "Usage:"
    echo -e "$0 FILE TAG_PREFIX"
    echo -e "\tFILE - file name and path to be signed"
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

function sign_canary {
	gpg --default-key D21FCEB2 --armor --output $file.sig.miczyg --sign --detach-sign $file
	error_check "Signing by Michał Żygowski failed"
	gpg --verify $file.sig.miczyg $file
	error_check "Verifying Michał Żygowski signature failed"
	gpg --default-key 67AA9E4C --armor --output $file.sig.piotr-krol --sign --detach-sign $file
	error_check "Signing by Piotr Król failed"
	gpg --verify $file.sig.piotr-krol $file
	error_check "Verifying Piotr Król signature failed"
}

function commit_changes {
	getnumber=(${file//-/ })
	number=${getnumber[1]##+(0)}
	git add $file
	git commit -m "Canary #$number"
	git add $file.sig.miczyg
	git commit -S6B5BA214D21FCEB2 -m "Canary #$number: sign"
	git_hash=$(git log --pretty=format:'%h' -n 1)
	full_hash=$(git log --pretty=format:'%H' -n 1)
	git tag -a -s -u 6B5BA214D21FCEB2 -m "Tag for commit $full_hash" miczyg_sec_${git_hash}
	git tag -v miczyg_sec_${git_hash}
	git add $file.sig.piotr-krol
	git config user.name "Piotr Król"
	git config user.email "piotr.krol@3mdeb.com"
	git commit -SB2EE71E967AA9E4C -m "Canary #$number: sign"
	git_hash=$(git log --pretty=format:'%h' -n 1)
	full_hash=$(git log --pretty=format:'%H' -n 1)
	git tag -a -s -u B2EE71E967AA9E4C -m "Tag for commit $full_hash" piotr-krol_sec_${git_hash}
	git tag -v piotr-krol_sec_${git_hash}
	git config user.name "Michał Żygowski"
	git config user.email "michal.zygowski@3mdeb.com"
}

function error_check {
	ERROR_CODE="$?"
	if [ "$ERROR_CODE" -ne 0 ]; then
		echo "$1 ($ERROR_CODE)"
		exit 1
	fi
}

if [ $# -le 0 ]; then
    usage
fi

file=$(basename "$1") 

if [ -f "$file" ]; then
	proof_of_freshness
	sign_canary
	commit_changes
else
	echo "$file not found."
	exit 1
fi
