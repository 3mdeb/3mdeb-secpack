# Most used commands

## Generate signature

```shell
gpg --default-key <my_key> --armor --output foo.txt.sig.<id> --sign --detach-sign foo.txt
```

Or by using script:

```shell
cd canaries/pcengines
../../scripts/sign.sh <canary_file> <tag_suffix>
```

This command will automatically generate signatures of Piotr Król and Michał
Żygowski and a signed tag with <tag_suffix> added to the tag name.

## Proof of freshness

Proof of freshness is automatically generated in signing script using sed.

Proof of freshness template format:

```shell
$ date -R -u

{date}

$ feedstail -1 -n5 -f '{title}' -u https://www.spiegel.de/international/index.rss

{freshness1}

$ feedstail -1 -n5 -f '{title}' -u https://rss.nytimes.com/services/xml/rss/nyt/World.xml

{freshness2}

$ feedstail -1 -n5 -f '{title}' -u https://feeds.bbci.co.uk/news/world/rss.xml

{freshness3}

$ feedstail -1 -n5 -f '{title}' -u http://feeds.reuters.com/reuters/worldnews

{freshness4}

$ curl -s 'https://blockchain.info/blocks/?format=json' |\
  python3 -c 'import sys, json; print(json.load(sys.stdin)['\''blocks'\''][10]['\''hash'\''])'

{blockchain_hash}
```