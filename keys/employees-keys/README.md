# 3mdeb GPG employee keys

This directory keeps 3mdeb employees keys and explains the procedure for adding
new keys.

## Adding key to the repository

1. [Create new GPG key](#how-to-create-a-new-gpg-key)
2. [Send key for signing](#sending-key-for-signing)
3. [Identity confirmation](#identity-confirmation)
4. [Key signing](#key-signing)
5. [Git configuration](#git-configuration)
6. [Create Pull Request with signed key](#create-pull-request-with-key)

If you have questions, please check [FAQ](#FAQ) section. Maybe the answer is
already there. If not, feel free to submit an issue to the repository.

### How to create a new GPG key

The following assumes that you have `gpg` installed.  The interaction is broken
into sections that correspond to user queries.

```
$ gpg --gen-key
```

For GPG version 2, you should use `gpg --full-generate-key`. Please note that
depending on the version of GPG you use, your output may look different.

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

Use a 2 years expiry key and then confirm your choice:

```
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 2y
Key expires at Fri 07 Apr 2023 11:40:33 AM CEST
Is this correct? (y/N) y
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

This is how it ends successfully (you might see a message about entropy
multiple times):

```
gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
pub   4096R/7429663E 2021-04-02
      Key fingerprint = 924C 1CD7 C19D 95FE 7A57  7D28 4857 9AA4 7429 663E
uid       [ultimate] Your Name <your.name@3mdeb.com>
sub   4096R/CC8BE1D5 2021-04-02
```

The key ID, in this case, is `7429663E`.

### Sending key for signing

Generate ASCII armor public key file:

```
gpg --armor --output your-name-key.asc --export "YOUR KEY ID HERE"
```

Obtain the fingerprint of your key:

```
gpg -n -q --import --import-options import-show your-name-key.asc
```

The armored public key should be sent to
[3mdeb chat web-of-trust channel](https://chat.3mdeb.com/team-3mdeb/channels/web-of-trust).

Please send fingerprint to 3mdeb Team Leaders or Management using a different
channel than 3mdeb chat, e.g., https://keybase.io, LinkedIn, email, etc.
Fingerprints should be sent to the person who works with you on signing your
keys.

### Identity confirmation

The following information is for 3mdeb Team Leaders or Management.

* If the official contract between employee and 3mdeb was signed, then national
  id verification was involved. In that case, Team Leader or Manager, based on
  a previous video call or live discussion during the recruitment process, can
  confirm that the employee sending keys is the same person who was hired. Also,
  a new employee should be the only one who has access to `@3mdeb.com` email
  address based on the secure credential passing procedure.
* If we establish keys for freelancer, who's identity cannot be confirmed by
  national id, video call, or face to face discussion, we rely on multiple
  Internet identities, e.g., Reddit, mailing list, Slack, Wire, Google email,
  Keybase, cryptocurrency address, etc. Freelancer has to confirm at least
  through 5 channels that he/she is the only person in control of.

We recommend creating [Keybase account](https://keybase.io) to simplify the
process of social proof multiple identities and tying those to give GPG key
pair. Please note that Keybase is not entirely open-source, so we should never
rely on only this single verification method.

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
$ gpg --check-sigs your.name@3mdeb.com
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
$ gpg -u piotr.krol@3mdeb.com --sign-key your.name@3mdeb.com

sec  rsa4096/BAA0A4837C891E29
     created: 2021-04-07  expires: 2023-04-07  usage: SC  
     trust: ultimate      validity: ultimate
ssb  rsa4096/4F81AE572F9EFECA
     created: 2021-04-07  expires: 2023-04-07  usage: E   
[ultimate] (1). Your Name <your.name@3mdeb.com>


sec  rsa4096/BAA0A4837C891E29
     created: 2021-04-07  expires: 2023-04-07  usage: SC  
     trust: ultimate      validity: ultimate
 Primary key fingerprint: D9DE EABF F447 B80F 7EC0  3A4B BAA0 A483 7C89 1E29

     Your Name <your.name@3mdeb.com>

This key is due to expire on 2023-04-07.
Are you sure that you want to sign this key with your
key "Piotr Król <piotr.krol@3mdeb.com>" (B2EE71E967AA9E4C)

Really sign? (y/N) y
```

Check signatures after signing:

```shell
$ gpg --check-sigs your.name@3mdeb.com
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

Please send the received key in an encrypted email to your.name@3mdeb.com.

```shell
gpg --armor --output your-name-key-signed.asc --export "YOUR KEY ID HERE"
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

Make sure your
[Github](https://docs.github.com/en/github/authenticating-to-github/telling-git-about-your-signing-key#telling-git-about-your-gpg-key-2)
and [Gitlab](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/index.html#adding-a-gpg-key-to-your-account) is set up correctly to provide GPG commit verification.


### Create a pull request with key

After everything is set up, please issue a pull request to this repo with signed
`your-name-key-signed.asc`.

### FAQ

#### What to do when this key expires?

There are 2 possible situations either it just expires, or it is
lost/compromised. In the first case, you should simply extend the validity time
as described [here](https://unix.stackexchange.com/a/177310) before the key
expires. Please note you should republish the key for which expiry was changed.
In the second case, you should revoke the key. The procedure is
[here](https://superuser.com/a/1526287).

#### If we extend expiry every time, why not set "key does not expire"? 

Because people forget about keys or stop using them for many reasons. If
someone extends expiry time, it means someone cares, and the key is still in
use.

