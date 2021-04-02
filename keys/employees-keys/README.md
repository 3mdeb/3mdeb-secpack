## How to create a new GPG key

The following assumes that you have `gpg` installed.  The interaction is broken
into sections that correspond to user queries.

```
$ gpg --gen-key
```

This is what you'll see if `gpg` is configured for the first time:

```
gpg (GnuPG) 2.0.31; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

gpg: directory `/home/emdeb/.gnupg' created
gpg: new configuration file `/home/emdeb/.gnupg/gpg.conf' created
gpg: WARNING: options in `/home/emdeb/.gnupg/gpg.conf' are not yet active during this run
gpg: keyring `/home/emdeb/.gnupg/secring.gpg' created
gpg: keyring `/home/emdeb/.gnupg/pubring.gpg' created
```

Pick "RSA and RSA" key:

```
Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
```

Use 4096 bits for key size:

```
RSA keys may be between 1024 and 4096 bits long.
@What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
```

Use a non-expiring key and then confirm your choice:

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
@Key is valid for? (0) 0
Key does not expire at all
@Is this correct? (y/N) y
```

Enter your real name:

```
GnuPG needs to construct a user ID to identify your key.

@Real name: Your Name
```

Company's email address:

```
@Email address: your.name@3mdeb.com
```

Comment field is optional:

```
@Comment:
```

Check and confirm your details:

```
You selected this USER-ID:
    "Your Name <your.name@3mdeb.com>"

@Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
```

Enter passphrase twice (second is confirmation):

```
You need a Passphrase to protect your secret key.
```

You might have to spend some time moving your mouse if entropy is low:

```
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
/home/emdeb/.gnupg/trustdb.gpg: trustdb created
gpg: key 7429663E marked as ultimately trusted
public and secret key created and signed.
```

This is how it ends successfully (you might see message about entropy multiple
times):

```
gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   4096R/7429663E 2021-04-02
      Key fingerprint = 924C 1CD7 C19D 95FE 7A57  7D28 4857 9AA4 7429 663E
uid       [ultimate] Your Name <your.name@3mdeb.com>
sub   4096R/CC8BE1D5 2021-04-02
```

The key ID in this case is `7429663E`.

## How to export your key

```
gpg --armor --output your-name-key.asc --export "YOUR KEY ID HERE"
```

Share `your-name-key.asc` textual file as the public portion of your key.
