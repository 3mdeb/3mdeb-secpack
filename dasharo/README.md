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
