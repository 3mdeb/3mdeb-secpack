Keys creation procedure
-----------------------

1. Create new key

```
$ gpg --expert --full-gen-key
gpg (GnuPG) 2.2.17; Copyright (C) 2019 Free Software Foundation, Inc.
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
Key expires at Thu 17 Sep 2020 03:10:24 PM CEST
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: PC Engines Open Source Firmware Release 4.10 Signing Key
Email address: 
Comment: 
You selected this USER-ID:
    "PC Engines Open Source Firmware Release 4.10 Signing Key"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key 233D0487B3A7A83C marked as ultimately trusted
gpg: revocation certificate stored as '-----------------'
public and secret key created and signed.

pub   rsa4096 2019-09-18 [SC] [expires: 2020-09-17]
      3B710228A4774C4FCB315876233D0487B3A7A83C
uid                      PC Engines Open Source Firmware Release 4.10 Signing Key
sub   rsa4096 2019-09-18 [E] [expires: 2020-09-17]
```
2. Import keys from offline storage

```
$ gpg --import /media/pietrushnic/backup/3mdeb-open-source-firmware-master-priv-key.asc
gpg: key 028A752764CB97EC: 1 signature not checked due to a missing key
gpg: key 028A752764CB97EC: public key "3mdeb Open Source Firmware Master Key <contact@3mdeb.com>" imported
gpg: key 028A752764CB97EC: secret key imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
gpg: public key of ultimately trusted key D346BEBC921DA640 not found
gpg: public key of ultimately trusted key 8A36B381A9C6508D not found
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   4  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 4u
gpg: next trustdb check due at 2020-09-17
[15:18:10] pietrushnic:~ $ gpg --import /media/pietrushnic/backup/3mdeb-master-priv-key.asc 
gpg: key 4AFD81D97BD37C54: public key "3mdeb Master Key <contact@3mdeb.com>" imported
gpg: key 4AFD81D97BD37C54: secret key imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
gpg: public key of ultimately trusted key D346BEBC921DA640 not found
gpg: public key of ultimately trusted key 8A36B381A9C6508D not found
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   4  signed:   1  trust: 0-, 0q, 0n, 0m, 0f, 4u
gpg: depth: 1  valid:   1  signed:   1  trust: 1-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2020-09-17
$ gpg --list-secret-keys
(...)

sec   rsa4096 2019-09-18 [SC] [expires: 2020-09-17]
      3B710228A4774C4FCB315876233D0487B3A7A83C
uid           [ultimate] PC Engines Open Source Firmware Release 4.10 Signing Key
ssb   rsa4096 2019-09-18 [E] [expires: 2020-09-17]

sec   rsa4096 2019-02-12 [SC]
      EA61CBADDA1C094A2540E596028A752764CB97EC
uid           [  undef ] 3mdeb Open Source Firmware Master Key <contact@3mdeb.com>

sec   rsa4096 2019-02-12 [SC]
      1B5785C2965D84CF85D1652B4AFD81D97BD37C54
uid           [  full  ] 3mdeb Master Key <contact@3mdeb.com>
```

3. Sign new release key with "3mdeb Open Source Firmware Master Key":

```
$ gpg -u EA61CBADDA1C094A2540E596028A752764CB97EC --sign-key 3B710228A4774C4FCB315876233D0487B3A7A83C
$ gpg --check-signatures 3B710228A4774C4FCB315876233D0487B3A7A83C
pub   rsa4096 2019-09-18 [SC] [expires: 2020-09-17]
      3B710228A4774C4FCB315876233D0487B3A7A83C
uid           [ultimate] PC Engines Open Source Firmware Release 4.10 Signing Key
sig!3        233D0487B3A7A83C 2019-09-18  PC Engines Open Source Firmware Release 4.10 Signing Key
sig!         028A752764CB97EC 2019-09-18  3mdeb Open Source Firmware Master Key <contact@3mdeb.com>
sub   rsa4096 2019-09-18 [E] [expires: 2020-09-17]
sig!         233D0487B3A7A83C 2019-09-18  PC Engines Open Source Firmware Release 4.10 Signing Key

gpg: 3 good signatures
```

3. Backup key to offline storage

```
gpg --export-secret-keys 3B710228A4774C4FCB315876233D0487B3A7A83C > /path/to/stoarge/pcengines-open-source-firmware-release-4.10-priv-key.asc
```

4. Move key to Yubikey

```
[15:46:11] pietrushnic:~ $ gpg --edit-key 3B710228A4774C4FCB315876233D0487B3A7A83C
gpg (GnuPG) 2.2.17; Copyright (C) 2019 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/233D0487B3A7A83C
     created: 2019-09-18  expires: 2020-09-17  usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/3B1FB40EAB542983
     created: 2019-09-18  expires: 2020-09-17  usage: E
[ultimate] (1). PC Engines Open Source Firmware Release 4.10 Signing Key

gpg> toggle

sec  rsa4096/233D0487B3A7A83C
     created: 2019-09-18  expires: 2020-09-17  usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/3B1FB40EAB542983
     created: 2019-09-18  expires: 2020-09-17  usage: E
[ultimate] (1). PC Engines Open Source Firmware Release 4.10 Signing Key

gpg> keytocard
Really move the primary key? (y/N) y
Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

sec  rsa4096/233D0487B3A7A83C
     created: 2019-09-18  expires: 2020-09-17  usage: SC
     trust: ultimate      validity: ultimate
ssb  rsa4096/3B1FB40EAB542983
     created: 2019-09-18  expires: 2020-09-17  usage: E
[ultimate] (1). PC Engines Open Source Firmware Release 4.10 Signing Key

gpg> key 1

sec  rsa4096/233D0487B3A7A83C
     created: 2019-09-18  expires: 2020-09-17  usage: SC
     trust: ultimate      validity: ultimate
ssb* rsa4096/3B1FB40EAB542983
     created: 2019-09-18  expires: 2020-09-17  usage: E
[ultimate] (1). PC Engines Open Source Firmware Release 4.10 Signing Key

gpg> keytocard
Please select where to store the key:
   (2) Encryption key
Your selection? 2

sec  rsa4096/233D0487B3A7A83C
     created: 2019-09-18  expires: 2020-09-17  usage: SC
     trust: ultimate      validity: ultimate
ssb* rsa4096/3B1FB40EAB542983
     created: 2019-09-18  expires: 2020-09-17  usage: E
[ultimate] (1). PC Engines Open Source Firmware Release 4.10 Signing Key

gpg> quit
```

5. Add public key to repo
