3mdeb Security Pack
===================

This git repository was inspired  by [Qubes Security Pack](https://github.com/QubesOS/qubes-secpack) and is a central place for all security-related information
about the 3mdeb projects. It includes the following:

 * 3mdeb PGP keys (`keys/`)
 * 3mdeb customers PGP keys (`customer-keys/`) - keys managed by 3mdeb on
   behalf of our customers, typically we use those keys for binaries signing

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
