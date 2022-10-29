# How to generate new Dasharo Release Signing Key?

## Generate key with correct name

For details about Dasharo keys naming please read
[documentation](https://docs.dasharo.com/dev-proc/versioning/#signing-keys).

```
$ gpg --expert --full-gen-key --allow-freeform-uid
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
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
  (13) Existing key
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
Key is valid for? (0) 1y
Key expires at Thu 10 Nov 2022 03:46:16 PM CET
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: <Platform Name> <Platform Model> Dasharo Release v0.x Signing Key
Email address:
Comment:
You selected this USER-ID:
    "<Platform Name> <Platform Model> Dasharo Release v0.x Signing Key"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key E28009DE6F9BB206 marked as ultimately trusted
gpg: revocation certificate stored as '/home/user/.gnupg/openpgp-revocs.d/BCAB910F26966C280BB1B6D0E28009DE6F9BB206.rev'
public and secret key created and signed.

pub   rsa4096 2021-11-10 [SC] [expires: 2022-11-10]
      BCAB910F26966C280BB1B6D0E28009DE6F9BB206
uid                      <Platform Name> <Platform Model> Dasharo Release v0.x Signing Key
sub   rsa4096 2021-11-10 [E] [expires: 2022-11-10]
```

## Work with release signing key

Three types of operations can be done with generated key. We can:

* export public key for verification purposes,
* use it to sign a release image,
* use along others public keys to verify release image.

### Exporting public key

After receiving the new key, signed with the public part of the key that you
have access to, please follow these steps to share the public part of new
release key by adding it to this, 3mdeb-secpack, repository.

* Decrypt new key

```
$ gpg --output <new-release-key-name>-priv.asc --decrypt <new-release-key-name>-priv.asc.gpg
gpg: encrypted with RSA key, ID 4AFAF0F5030D9986
gpg: encrypted with 4096-bit RSA key, ID 9CCACA8E3F071202, created 2021-09-07
      "Name Name (key-name) <name.name@3mdeb.com>"
```

* Import private key locally

```
$ gpg --import <new-release-key-name>-priv.asc
gpg: key 9CEA8904377B8F3D: 1 signature not checked due to a missing key
gpg: key 9CEA8904377B8F3D: public key "<public-key-name>" imported
gpg: key 9CEA8904377B8F3D: secret key imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
gpg: no ultimately trusted keys found
```

* Export public key

```
$ gpg --output <new-release-key-name>-pub.asc --export -a "<public-key-name>"
$ cat <new-release-key-name>-pub.asc
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGMRGVABEADgzHyYjrLJFjhk8Z6bFwKopUR3UrneVJmnkxiiKPDpsISgYmER
(...)
gqIlKm0GTr3LSMrGv0SuciSz6EwL0S8j2aaNs8igLZ3pyLCcXfUEKi7p01c87HM0
lZSo4cm/iZxp+Uv1BdBwI8Qy0hJMLw9hmaIY0nET+Ik=
=mpVm
-----END PGP PUBLIC KEY BLOCK-----
```

* Create new PR and add public key (file `<new-release-key-name>-pub.asc`) to
  the repository, similar to
  [previous](https://github.com/3mdeb/3mdeb-secpack/pull/63) PRs

### Signing release image

To sign release image, please use imported private release signing key to create
signature. Commands below assumes, that private key is already imported, as
shown in previous [section](#exporting-public-key).

* Create hash of release image

```
$ sha256sum <release-image> <release-image>.sha256
$ cat <release-image>.sha256
7c50c01a7402a6c6c911061faf9bba5161edae27577168ea94969c0159b2e77f    <release-image>
```

* Create signature, use public key exported in previous
  [section](#exporting-public-key).

```
$ gpg --local-user "<public-key-name>" --output <release-image>.sha256.sig --armor --detach-sig <release-image>.sha256
```

### Verifying release image

Every new release image key is created with chain of keys. In case of Dasharo
release keys those are:

* `3mdeb Master Key`,
* `3mdeb Dasharo Master Key`.

Public parts of those will be needed to fully verify created signature along
with public part of new key, release image with signature and hash.

* Place release image, signature and hash in one directory

```
$ ls <release-image>*
<release-image>  <release-image>.sha256  <release-image>.sha256.sig
```

* Verify hash

```<public-key-name>
$ sha256sum -c <release-image>.sha256
<release-image>: OK
```

* Fetch public keys

```
$ gpg --fetch-keys https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/keys/master-key/3mdeb-master-key.asc
gpg: requesting key from 'https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/keys/master-key/3mdeb-master-key.asc'
gpg: key 4AFD81D97BD37C54: public key "3mdeb Master Key <contact@3mdeb.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
$ gpg --fetch-keys https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/dasharo/3mdeb-dasharo-master-key.asc
gpg: requesting key from 'https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/dasharo/3mdeb-dasharo-master-key.asc'
gpg: key ABE1D0BC66278008: public key "3mdeb Dasharo Master Key" imported
gpg: Total number processed: 1
gpg:               imported: 1
$ gpg --fetch-keys https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/dasharo/<release>/<new-release-key-name>-pub.asc
gpg: requesting key from 'https://raw.githubusercontent.com/3mdeb/3mdeb-secpack/master/dasharo/<release>/<new-release-key-name>-pub.asc'
gpg: key 9CEA8904377B8F3D: public key "<public-key-name>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

* Verify signature

```
$ gpg -v --verify <release-image>.sha256.sig
gpg: assuming signed data in '<release-image>.sha256'
gpg: Signature made pią, 2 wrz 2022, 08:56:07 CEST
gpg:                using RSA key 0B2416EC1A65A88CEBA809329CEA8904377B8F3D
gpg: using pgp trust model
gpg: Good signature from "<public-key-name>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 0B24 16EC 1A65 A88C EBA8  0932 9CEA 8904 377B 8F3D
gpg: binary signature, digest algorithm SHA512, key algorithm rsa4096
```
