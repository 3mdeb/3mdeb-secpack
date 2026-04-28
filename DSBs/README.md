# Dasharo Security Bulletins

This directory contains all published Dasharo Security Bulletins (DSBs).

Each bulletin is a plain-text file accompanied by one or more detached PGP
signatures from members of the Dasharo Security Team. To verify a bulletin:

```bash
gpg --verify dsb-NNN-YYYY-MM-DD.txt.sig.<signer> dsb-NNN-YYYY-MM-DD.txt
```

Public keys for authorized signers are managed in the root of this repository.

## Bulletins

| ID      | Date       | Title                                                   |
|---------|------------|---------------------------------------------------------|
| DSB-001 | 2025-12-22 | Wrong Intel Boot Guard fusing prevents further updates  |

## Creating a new DSB

Use the scaffold script:

```bash
./scripts/dsb-new.sh --title "Short title of the issue"
```
