# 3mdeb Security Pack

This git repository was inspired  by the
[Qubes Security Pack](https://github.com/QubesOS/qubes-secpack) and is a central
place for all security-related information about the 3mdeb projects. It includes
the following:

* 3mdeb customers PGP keys (`customer-keys/`) - keys managed by 3mdeb on
   behalf of our customers, typically we use those keys for binaries signing
* Dasharo keys (`dasharo/`) - Dasharo Master Key used to sign Dasharo keys
   related to market segments (Secure Firewall, Workstation), as well as
   Dasharo market segment firmware release signing keys, to read more about
   Dasharo visit [website](https://dasharo.com/) and
   [documentation](https://docs.dasharo.com/)
* 3mdeb PGP keys (`keys/`)
    - `employees-keys` -  3mdeb employees keys signed according to org chart,
     chain of signatures end with `owner-key` signature
    - `master-key` - 3mdeb Master Key signs all keys dedicated to given purpose
     e.g. Open Source Software Release Signing Key, Open Source Firmware
     Release Signing Key and others
    - `owner-key` - 3mdeb Owner Key
* 3mdeb Open Source Firmware Master Key (`open-source-firmware/`) - key used
   to sign firmware releases produced by 3mdeb
* 3mdeb Open Source Software Master Key (`open-source-software/`) - key used
   to sign software releases produced by 3mdeb
* Supporting scripts (`scripts/`)

The files contained in this repository can be verified in two ways:

* By verifying the git commit tags (`git tag -v`)
* By verifying the detached PGP signatures, which are provided for the majority
   of files included here

All the keys used by the 3mdeb projects, including the keys used to sign files
and commits in this repository, are signed by the 3mdeb owner Piotr Król
(`E0309B2D85A67E846329E34BB2EE71E967AA9E4C`, [keybase.io](https://keybase.io/pietrushnic)).

Even though this key is also included in this repo, you should make sure to
obtain the key fingerprint via some other channel, as you can be sure
that if you were getting a falsified 3mdeb Security Pack it would contain a
falsified owner key as well.

## git-secrets setup

Below configuration would prevent you from accidentaly commiting private keys
into the repository.

* Install [git-secrets](https://github.com/awslabs/git-secrets) via one of the
  supported installation options

* Add pre-commit hooks to this repo:

```shell
$ git secrets --install
$ git secrets --add 'PRIVATE[[:space:]]KEY'
```

* Trying to commit private key would result in following message:

```shell
FILE_NAME:1:-----BEGIN PGP PRIVATE KEY BLOCK-----
FILE_NAME:118:-----END PGP PRIVATE KEY BLOCK-----

[ERROR] Matched one or more prohibited patterns

Possible mitigations:
- Mark false positives as allowed using: git config --add secrets.allowed ...
- Mark false positives as allowed by adding regular expressions to .gitallowed at repository's root directory
- List your configured patterns: git config --get-all secrets.patterns
- List your configured allowed patterns: git config --get-all secrets.allowed
- List your configured allowed patterns in .gitallowed at repository's root directory
- Use --no-verify if this is a one-time false positive
```

# Adding new Master Key

```shell
user@vault ~ % gpg --expert --full-gen-key --allow-freeform-uid
gpg (GnuPG) 2.1.18; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want for the subkey? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 5y
Key expires at Mon 02 Feb 2026 01:28:36 PM CET
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: 3mdeb Dasharo Master Key
Email address: 
Comment: 
You selected this USER-ID:
    "3mdeb Dasharo Master Key"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key ABE1D0BC66278008 marked as ultimately trusted
gpg: revocation certificate stored as '/home/user/.gnupg/openpgp-revocs.d/0D5F6F1DA800329EB7C597A2ABE1D0BC66278008.rev'
public and secret key created and signed.

pub   rsa4096 2021-02-03 [SC] [expires: 2026-02-02]
      0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
      0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
uid                      3mdeb Dasharo Master Key
sub   rsa4096 2021-02-03 [E] [expires: 2026-02-02]
user@vault ~ % gpg --export-secret-keys 0D5F6F1DA800329EB7C597A2ABE1D0BC66278008 > 3mdeb-dasharo-master-priv-key.asc
user@vault ~ % gpg --recipient piotr.krol@3mdeb.com --armor --encrypt 3mdeb-dasharo-master-priv-key.asc
```

Store backup of private key in safe location.
