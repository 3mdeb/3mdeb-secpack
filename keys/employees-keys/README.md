# 3mdeb GPG employee keys

This directory keeps 3mdeb employees keys and explains the procedure for adding
new keys.

## Table of contents

* [Adding key to the repository](#adding-key-to-the-repository)
* [FAQ](#faq)
    - [What to do when this key expires?](#what-to-do-when-this-key-expires)
    - [If we extend expiry every time, why not set "key does not
    expire"?](#if-we-extend-expiry-every-time-why-not-set-key-does-not-expire)
    - [What to do when primary/master private key was lost, compromised or will no longer be used?](#what-to-do-when-primarymaster-private-key-was-lost-compromised-or-will-no-longer-be-used)

## Adding key to the repository

To add new key to this repository you should:

1. [Create new GPG key](#create-a-new-gpg-key)
2. [Encrypt revocation cert](#encrypt-revocation-cert)
3. [Send key for signing and revocation
   cert](#sending-key-for-signing-and-revocation-cert)

Then 3mdeb Team Leader or Management should

1. [3mdeb Team Leader/Management: Identity
   confirmation](#identity-confirmation)
2. [3mdeb Team Leader/Management: Key signing](#key-signing)

Finally you should configure your git and provide signed key through pull
request:

1. [Git configuration](#git-configuration)
2. [Create Pull Request with signed key](#create-a-pull-request-with-key)
3. [Upload to keys.opengpg.org](#upload-to-keysopengpgorg)

If you have questions, please check [FAQ](#FAQ) section. Maybe the answer is
already there. If not, feel free to submit an issue to the repository.

### Create a new GPG key

The following assumes that you have `gpg` installed.  The interaction is broken
into sections that correspond to user queries.

Clone repository:

```shell
git clone https://github.com/3mdeb/3mdeb-secpack.git
```

Change directory:

```shell
cd 3mdeb-secpack/scripts
```

Generate key:

```shell
./gen-new-employee-key.sh "Your Name" "your.name@3mdeb.com"
```

Please note your key id printed at the end:

```shell
(...)
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

Your KEY_ID: D9E4EB63705C3897
```

#### Key identification

GPG key is identified by it's fingerprint we can see it using the
following command.

```shell
gpg --list-keys your.name@3mdeb.com
```

Output will look as follows:

```shell
pub   rsa4096 2024-11-19 [C]
      EF0E14600FE8F480A91D2C9C234A47C68C319635
uid           [ultimate] Your Name (Employee Cert Key) <your.name@3mdeb.com>
sub   rsa4096 2024-11-19 [S] [expires: 2025-11-19]
sub   rsa4096 2024-11-19 [E] [expires: 2025-11-19]
```

In this case`EF0E14600FE8F480A91D2C9C234A47C68C319635` is the fingerprint of the
primary key. This is a hexadecimal number.

There are another two identifiers of GPG keys derived from the fingerprint:
* Long key id - lower 16 digits of the fingerprint in our example `234A47C68C319635`
* Short key id - lower 8 digits of the fingerprint in our example `8C319635`

Please be aware that every GPG key has it's unique fingerprint.
By default `gpg --list-keys` displays only the master key fingerprint.
To see fingerprints of all keys we should use:

```shell
gpg --list-keys --with-subkey-fingerprints your.name@3mdeb.com
```

#### Key hierarchy

Let's learn about key hierarch that above script created for us. Let's use
following key as example:

```shell
vault% gpg --edit-key A23A22E7ECF08AE4
(...)

Secret key is available.

sec  rsa4096/A23A22E7ECF08AE4
     created: 2023-10-17  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb  rsa4096/EF24B10EB949136C
     created: 2023-10-17  expires: 2024-10-16  usage: S
ssb  rsa4096/F6B7D64D8E32E5CB
     created: 2023-10-17  expires: 2024-10-16  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>
```

We see three keys:
* `A23A22E7ECF08AE4` - Main/Master/Primary Key (`usage: C` - Certifying Key)
    - `EF24B10EB949136C` - Signing Subkey (`usage: S`)
    - `F6B7D64D8E32E5CB` - Encryption Subkey (`usage: E` )

There is also possible `A` authentication key.

The Main/Master/Primary Key is the cornerstone of a public key infrastructure,
representing a user's core digital identity. Its main role is to certify other
keys (including subkeys), ensuring their authenticity. Due to its critical
importance, it's often securely stored, sometimes offline, to prevent
compromises. While it typically has a longer lifespan than subkeys, its
compromise can lead to the revocation of associated subkeys, underlining its
central position in the trust hierarchy.

Subkeys are extensions of the master key in a public key infrastructure,
designed for specific cryptographic tasks like signing, encryption, or
authentication. They allow users to separate routine operations from the
primary identity represented by the master key. Subkeys inherit trust from
their master key, meaning if someone trusts the master key, they inherently
trust its subkeys. This structure provides flexibility: subkeys can be rotated
or revoked individually without affecting the master key, enabling enhanced
security and adaptability in cryptographic operations. In practice, users might
use subkeys for daily tasks, keeping them more accessible, while the master key
remains securely stored.

### Encrypt revocation cert

Import 3mdeb Founder key:

```shell
gpg --import  keys/owner-key/piotr-krol-key.asc
```

Import your 3mdeb Team Leader or Manager key:

```shell
gpg --import keys/employees-keys/your-tl-or-mgr-name-key-signed.asc
```

Encrypt your revocation certificate (please use your KEY_ID from previous
point):

```shell
gpg --encrypt -r piotr.krol@3mdeb.com -r your.tl-or-mgr-name@3mdeb.com -o \
your.name@3mdeb.com.rev.gpg ${HOME}/.gnupg/openpgp-revocs.d/*KEY_ID.rev
```

Output should look as follows:

```shell
gpg: 4AFAF0F5030D9986: There is no assurance this key belongs to the named user

sub  rsa4096/4AFAF0F5030D9986 2020-01-24 Your TL/MGR <your.tl-or-mgr-name@3mdeb.com>
 Primary key fingerprint: A766 C895 6989 5C0B 86D5  98D0 9963 C36A AC3B 2B46
      Subkey fingerprint: 6D03 D384 2A29 89A8 9402  DC4C 4AFA F0F5 030D 9986

It is NOT certain that the key belongs to the person named
in the user ID.  If you *really* know what you are doing,
you may answer the next question with yes.

Use this key anyway? (y/N) y
```

### Sending key for signing and revocation cert

The armored public key (`your.name@3mdeb.com.asc`) and encrypted revocation
certificate (`your.name@3mdeb.com.rev.gpg`) should be sent to [3mdeb chat
web-of-trust channel](https://chat.3mdeb.com/team-3mdeb/channels/web-of-trust).

Please send [fingerprint](#key-identification) to 3mdeb Team Leaders or
Management using a different channel than 3mdeb chat, e.g.,
<https://keybase.io>, LinkedIn, email, etc. Fingerprints should be sent
to the person who works with you on signing your keys.

### Identity confirmation

The following information is for 3mdeb Team Leaders or Management.

* If the official contract between employee and 3mdeb was signed, then national
  id verification was involved. In that case, Team Leader or Manager, based on
  a previous video call or live discussion during the recruitment process, can
  confirm that the employee sending keys is the same person who was hired.
  Also, a new employee should be the only one who has access to `@3mdeb.com`
  email address based on the secure credential passing procedure.
* If we establish keys for freelancer, who's identity cannot be confirmed by
  national id, video call, or face to face discussion, we rely on multiple
  Internet identities, e.g., Reddit, mailing list, Slack, Wire, Google email,
  Keybase, cryptocurrency address, etc. Freelancer has to confirm at least
  through 5 channels that he/she is the only person in control of.

### Key signing

3mdeb Team Leaders and Management should carefully confirm identity if any
the concern arises, it should be reported to higher management.

Check received key fingerprint:

```shell
gpg -n -q --import --import-options import-show your-name-key.asc
```

If it matches the fingerprint received by another channel and the identity was
confirmed, you can proceed with signing. First import key:

```shell
gpg --import your-name-key.asc
```

Check signatures before signing:

```shell
gpg --check-sigs your.name@3mdeb.com
```

Output:

```shell
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   7  signed:   6  trust: 0-, 0q, 0n, 0m, 0f, 7u
gpg: depth: 1  valid:   6  signed:   1  trust: 6-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2021-11-23
pub   rsa4096 2021-04-07 [SC] [expires: 2023-04-07]
      D9DEEABFF447B80F7EC03A4BBAA0A4837C891E29
uid           [ultimate] Your Name <your.name@3mdeb.com>
sig!3        BAA0A4837C891E29 2021-04-07  Your Name <your.name@3mdeb.com>
sub   rsa4096 2021-04-07 [E] [expires: 2023-04-07]
sig!         BAA0A4837C891E29 2021-04-07  Your Name <your.name@3mdeb.com>

gpg: 2 good signatures
```

Signing should look as follows. If fingerprint match, then confirm with `y'.

```shell
gpg -u piotr.krol@3mdeb.com --ask-cert-level --ask-cert-expire --sign-key your.name@3mdeb.com
```

Output:

```shell

gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:  12  signed:   6  trust: 0-, 0q, 0n, 0m, 0f, 12u
gpg: depth: 1  valid:   6  signed:  17  trust: 6-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2025-06-06
pub  rsa4096/6B5BA214D21FCEB2
     created: 2017-10-31  expires: 2026-03-26  usage: SC
     trust: unknown       validity: unknown
sub  rsa4096/3B7D01F9092DB189
     created: 2017-10-31  expires: 2026-03-26  usage: E
sub  rsa4096/29A63FE152E1ADF9
     created: 2021-06-27  expires: 2026-03-26  usage: A
[ unknown] (1). Your Name <your.name@3mdeb.com>


pub  rsa4096/6B5BA214D21FCEB2
     created: 2017-10-31  expires: 2026-03-26  usage: SC
     trust: unknown       validity: unknown
 Primary key fingerprint: 00B8 8FB2 5FD6 375B C5FF  195D 6B5B A214 D21F CEB2

     Your Name <your.name@3mdeb.com>

This key is due to expire on 2026-03-26.
Do you want your signature to expire at the same time? (Y/n) n
Please specify how long the signature should be valid.
         0 = signature does not expire
      <n>  = signature expires in n days
      <n>w = signature expires in n weeks
      <n>m = signature expires in n months
      <n>y = signature expires in n years
Signature is valid for? (0) 351
Signature expires at Thu 26 Mar 2026 11:09:34 PM CET
Is this correct? (y/N) y
How carefully have you verified the key you are about to sign actually belongs
to the person named above?  If you don't know what to answer, enter "0".

   (0) I will not answer. (default)
   (1) I have not checked at all.
   (2) I have done casual checking.
   (3) I have done very careful checking.

Your selection? (enter '?' for more information): 3
Are you sure that you want to sign this key with your
key "Piotr Król (Employee Cert Key) <piotr.krol@3mdeb.com>" (67D4F3E372CBC3A9)

I have checked this key very carefully.

Really sign? (y/N) y
```

Check signatures after signing:

```shell
gpg --check-sigs your.name@3mdeb.com
```

Output:

```text
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   7  signed:   6  trust: 0-, 0q, 0n, 0m, 0f, 7u
gpg: depth: 1  valid:   6  signed:   1  trust: 6-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2021-11-23
pub   rsa4096 2021-04-07 [SC] [expires: 2023-04-07]
      D9DEEABFF447B80F7EC03A4BBAA0A4837C891E29
uid           [ultimate] Your Name <your.name@3mdeb.com>
sig!3        BAA0A4837C891E29 2021-04-07  Your Name <your.name@3mdeb.com>
sig!         B2EE71E967AA9E4C 2021-04-07  Piotr Król <piotr.krol@3mdeb.com>
sub   rsa4096 2021-04-07 [E] [expires: 2023-04-07]
sig!         BAA0A4837C891E29 2021-04-07  Your Name <your.name@3mdeb.com>

gpg: 3 good signatures
```

Please send the received key in an encrypted email to <your.name@3mdeb.com>.

```shell
gpg --armor --output your-name-key-signed.asc --export "YOUR KEY ID HERE"
```

Expired signature would look as follows in the output:

```text
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:  13  signed:   7  trust: 0-, 0q, 0n, 0m, 0f, 13u
gpg: depth: 1  valid:   7  signed:  17  trust: 7-, 0q, 0n, 0m, 0f, 0u
gpg: next trustdb check due at 2025-06-06
pub   rsa3072/8E5047CD480AAE7C 2023-10-03 [SC]
      Key fingerprint = F673 50A9 A484 D2D3 0987  0C81 8E50 47CD 480A AE7C
uid                 [ultimate] SigExpireTest
sig 3        8E5047CD480AAE7C 2023-10-03  SigExpireTest
sig 1     X  40BABCE7542B0B4A 2023-10-03  Piotr Król Signature After Expiration Date (Employee Cert Key) <piotr.krol@3mdeb.com>
sub   rsa3072/9D6E6BCE09664EE1 2023-10-03 [E]
      Key fingerprint = 23DE CB8C 3E63 D7A0 4FE4  C9C5 9D6E 6BCE 0966 4EE1
sig          8E5047CD480AAE7C 2023-10-03  SigExpireTest
```

### Git configuration

The generated key should be used for signing every commit you push on behalf of
3mdeb. Detailed instruction for git configuration can be found
[here](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work). In short
you need the following in `~/.gitconfig`:

```bash
[alias]
        ci = commit -s -S
[user]
        name = Your Name
        email = your.name@3mdeb.com
        signingkey = 48579AA47429663E
```

Please note that `signingkey` should contain Fingerprints of the key with
`usage: S` as explained in section [key hierarchy](#key-hierarchy).

Make sure your
[Github](https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key#telling-git-about-your-gpg-key-2)
and
[Gitlab](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/index.html#adding-a-gpg-key-to-your-account)
is set up correctly to provide GPG commit verification.

### Configuring Thunderbird

To send and receive end-to-end encrypted emails using Thunderbird you need
to tell it to use the gpg keyring by modifying the config:
`Settings -> General -> Config Editor... -> mail.opengp.allow_external_gnupg`
Set the value to true and restart Thunderbird. Now when opening an encrypted
email a prompt to unlock the gpg keyring should appear and the email will be
decrypted given it was encrypted with your public key.

### Create a pull request with key

After everything is set up, please issue a pull request to this repo with
signed `your-name-key-signed.asc`. Before you create a pull request
please verify if the commit with your key is correct:

* At the end of your commit message there should be a line saying
`Signed-off by Your Name <your.name@3mdeb.com>`. If you configure git
as shown [here](#git-configuration) and use `git ci` alias to commit
this will happen automatically.
* Name of the commit should follow `<scope>: <type> <description>` style
* The commit status on Github should be `Verified`. You can check that by
navigating to `github.com/3mdeb/3mdeb-secpack/commit/your-commit-id`:
    - Verified commit look like [this](https://github.com/3mdeb/3mdeb-secpack/commit/9930a5d7009d8abc77544dc081ded77276710cf3)
   note the green field saying Verified to the left of the screen.
    - Non verified commit will look like [this](https://github.com/3mdeb/3mdeb-secpack/commit/c8219a1e0a3531c854c73eab5c886817e7323a08)
   the field that was green is now yellow and says Unverified.
    - If your commit is not verified this means that you either did
    not sign it correctly `-S` flag in `git commit` or your GPG key on
    Github was not added correctly.

After you verified that all those things are correct you can create a
pull request.

### Upload to keys.opengpg.org

* Go to <https://keys.openpgp.org>.
* Upload Your Key:
    - On the main page, you'll see an "Upload" section.
    - Click on the "Choose File" button and select the <your.name@3mdeb.com.asc>
    file you just created.
    - Click on the "Upload" button.
* Verify Your Email Address:
    - <https://keys.openpgp.org> will send you an email to verify that the email
    address associated with the key is valid.
    - Open the email and click on the verification link.
    - Once verified, your key will be added to the keys.openpgp.org keyserver.
* After uploading and verifying, you can search for your key on the keyserver
  using your email address to ensure it's been uploaded correctly.

## FAQ

### What to do when this key expires?

There are 2 possible situations either it just expires, or it is
lost/compromised. In the first case, you should simply extend the validity time
as described [here](https://unix.stackexchange.com/a/177310). Please note you
should republish the key for which expiry was changed, but before you can do
that your key with new expiry date have to be
[signed](#sending-key-for-signing-and-revocation-cert) by Team Leader or
someone from Management.

Republishing should happen for all cloud git servers you use and would like to
have `verified` marking, so it probably means GitHub, GitLab and 3mdeb Gitea.
In most cases it means removing old GPG key and uploading update one, this is
because expired and new key have the same fingerprint and you cannot have two
keys with the same fingerprint.

In the second case please follow [this
guide](#what-to-do-when-primarymaster-private-key-was-lost-compromised-or-will-no-longer-be-used).

### If we extend expiry every time, why not set "key does not expire"?

Because people forget about keys or stop using them for many reasons. If
someone extends expiry time, it means someone cares, and the key is still in
use.

<!-- markdownlint-disable-next-line -->
### What to do when primary/master private key was lost, compromised or will no longer be used?

Following guide was made for:
* recovery in case of losing access to you primary/master private key,
* evidence of primary/master key compromise,
* event when employee of 3mdeb finished his/her cooperation and should no longer
  sign 3mdeb related development work.

Guide is made with assumption, that you still have access to:
* private key or at least previously generated revocation certificate - please
  note that gpg save revocation certificate automatically on machine you
  generated key in `/home/USERNAME/.gnupg/openpgp-revocs.d/KEYID.rev`
* list of servers to which your key was uploaded - in theory servers should
  sync between each other,
* list of keys you signed - check below how to obtain it,

Correct key management would require use of subkeys and private part of your
master key should never be lost because it should be stored in a safe location.

#### Inform your Team Leader or Manager

Please immiedietly let know your 3mdeb Team Leader or Manager about potential
problem with your GPG keys. Delaying this process you put 3mdeb at risk of
compromise.

#### Generate revocation certificate

If you don't have revocation certificate, but have access to private key please
generate revocation certificate by using:

```shell
gpg --output revoke.asc --gen-revoke KEYID
```

Where `KEYID` is the id of the key which you would like to revoke.

#### Revoke your key

```shell
gpg --import your.name@3mdeb.com.rev
```

#### Change expiration date

In situations where there's a potential compromise of a GPG key, it might be
necessary to change the expiration date of the key to the last known safe date.
This ensures that the key is no longer valid after the potential compromise,
adding an extra layer of security.

Because last known safe date is in the past and we can set expiration date only
for future we have to change system time before we can proceed. Let's assume
our last safe date is 2023-10-06 07:08:03 PM. So we have to deliberately use
one day before (5th October).

That change of system time is temporary most distributions synchronize time
with network time servers, e.g. on Fedora there is about 10 minutes before it
resets to current time, but on Ubuntu it works only for a fraction of second.
In Qubes OS AppVMs are synchronized by Dom0 periodically every 6h, but sync can
be triggered by `sudo qvm-sync-clock`.

Please choose mechanism of setting time of your system wisely or ask for help.
Just in case before setting time let's stop system time synchronization
service:

```shell
sudo service systemd-timesyncd stop
```

```shell
sudo date -s "2023-10-05 07:08:03 PM"
```

Now let's expire our main and associated subkeys:

```shell
gpg --edit-key KEYID
```

Procedure should look as follows:

```shell
gpg (GnuPG) 2.2.40; Copyright (C) 2022 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb  rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2024-05-04  usage: S
ssb  rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2024-05-04  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> expire
Changing expiration time for the primary key.
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1d
Key expires at Fri 06 Oct 2023 07:08:05 PM CEST
Is this correct? (y/N) y

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: 2023-10-06  usage: C
     trust: ultimate      validity: ultimate
ssb  rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2024-05-04  usage: S
ssb  rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2024-05-04  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> key 1

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: 2023-10-06  usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2024-05-04  usage: S
ssb  rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2024-05-04  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> expire
Changing expiration time for a subkey.
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1d
Key expires at Fri 06 Oct 2023 07:08:20 PM CEST
Is this correct? (y/N) y

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: 2023-10-06  usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2023-10-06  usage: S
ssb  rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2024-05-04  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> key 2

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: 2023-10-06  usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2023-10-06  usage: S
ssb* rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2024-05-04  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> expire
Are you sure you want to change the expiration time for multiple subkeys? (y/N) y
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1d
Key expires at Fri 06 Oct 2023 07:08:35 PM CEST
Is this correct? (y/N) y

sec  rsa4096/8895D29C1B822905
     created: 2023-05-05  expires: 2023-10-06  usage: C
     trust: ultimate      validity: ultimate
ssb* rsa4096/1B1C3210563730D9
     created: 2023-05-05  expires: 2023-10-06  usage: S
ssb* rsa4096/1F97D67F4B465248
     created: 2023-05-05  expires: 2023-10-06  usage: E
[ultimate] (1). Your Name (Employee Cert Key) <your.name@3mdeb.com>

gpg> save
```

Start system time synchronization again:

```shell
sudo service systemd-timesyncd stop
```

#### Upload revoked and expired key to the servers

Following this set of commands assumes that the machine on which you applied revocation
and machine on which you publish revoked key are different. If it is not the case,
you can skip export step.

Export revoked public key:

```shell
gpg --export -a KEYID > KEYID_revoked.asc
```

Move `KEYID_revoked.asc` to upload machine and import

```shell
gpg --import KEYID_revoked.asc
```

Send to server:

```shell
gpg --keyserver KEYSERVER --send-keys KEYID
```

Where typical `KEYSERVER` would be `https://keyserver.ubuntu.com` and
`https://keys.openpgp.org`.

#### New keys

Before proceeding create new keys following [standard
procedure](#adding-key-to-repository).

#### Revoke key in Thunderbird

* Import revocation certificate into Thunderbrid
    - Tools > OpenPGP Key Manager > File > Import Revocation(s) From File
* If your new key was uploaded to keys.opengpg.org use Keyserver > Discover
  Keys Online
* Replace key in Settings > Account Settings, choose your account End-To-End
  Encryption > Add Key ... > Use your external key through GnuPG, hit Continue
  and provide fingerprint of your certifying key.

#### Gitlab, Github and Gitea revocation

Go to all websites where you used your GPG key. Delete key which you revoked
and expired. After deleting upload key which contain revocation and expiration
signature. On Github it should look as follows:

![](/img/certify_key_revoked.png)

Commits should looks as follows:

![](/img/certify_key_revoked_commit.png)

#### Obtain list of keys you signed

Following procedure looks through keyring, so it should be prepared in
environment which is used to signing operations. For Qubes OS it would be vault
VM.

```shell
for i in $(gpg --list-keys --with-colons | awk -F: '/^fpr/ {print $10}'|xargs);do
	if gpg --list-sigs $i|grep -q -E "^sig\s+$(echo KEYID | tail -c 17)";then
		echo $i
	fi
done
```

It produces a list of keys that have to be signed by a new key.

#### Visit cards

If you use 3mdeb visit cards, then section with key become useless. Make sure
to wipe key with black marker or request creation of new visit cards.
