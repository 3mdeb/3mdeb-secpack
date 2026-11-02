# Upstream advisories

Security advisories of upstream projects, such as coreboot and EDK II, and
whether they affect Dasharo. Modelled on the
[Qubes XSA tracker](https://www.qubes-os.org/security/xsa/).

Edit [upstream-advisories.yml](upstream-advisories.yml) and run
`scripts/upstream-advisories.py` to regenerate the table. The pre-commit hook
fails if the table is out of date.

## Advisories

<!-- BEGIN generated from upstream-advisories.yml, do not edit -->
| Advisory | CVE | Upstream | Published | Current releases | Earlier releases | DSB | Checked |
|---|---|---|---|---|---|---|---|
| [GHSA-99cj-7hg9-mp4m](https://github.com/tianocore/edk2/security/advisories/GHSA-99cj-7hg9-mp4m) | CVE-2026-97631 | EDK II (NetworkPkg/UefiPxeBcDxe) | 2026-10-22 | No | Yes | [DSB-003](../DSBs/dsb-003-2026.txt) | 2026-11-02 |

### GHSA-99cj-7hg9-mp4m

Current releases do not build the EDK II network stack. Some 2022 releases did.
We found no way to reach the driver in them. DSB-003 lists them and the version
to use.

Evidence: <https://blog.3mdeb.com/2026/2026-10-29-dasharo-edk2-pxe-cve-2026-97631/>
<!-- END generated -->

## Columns

* **Current releases**: is the latest Dasharo (coreboot+UEFI) release of any
  platform affected? If yes, a DSB says which and what to do.
* **Earlier releases**: is any earlier release affected? If yes, the DSB lists
  them and the version to use.
* **DSB**: the Dasharo Security Bulletin, if any.
* **Checked**: date of the last check. We update the entry when a release
  changes the answer.

"Yes" means the advisory applies to Dasharo: the vulnerable code is in the
release and we could not rule out that it can be reached. "No" means it is not
in the release, or we showed it cannot be reached. The text under the table
explains the answer.

## Scope

* We follow the security advisories of the upstream projects Dasharo is built
  from, such as coreboot, EDK II and iPXE.
* Embargoed advisories are added after disclosure.
* Dates are UTC.
