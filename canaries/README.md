Most used commands
------------------

# Generate signature

```
gpg --default-key <my_key> --armor --output foo.txt.sig.<id> --sign --detach-sign foo.txt
```

Or by using script:

```
cd canaries/pcengines
../../scripts/sign.sh <canary_file> <key_id> <id>
```

Or:

```
cd canaries/pcengines
../../scripts/sign.sh <canary_file>
```

This command will automatically generate signatures of Piotr Król and Michał
Żygowski.
