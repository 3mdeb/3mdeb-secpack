# Customer keys

## How to generate new customer key

```shell
./scripts/new-customer-key.sh
```

Example:
```shell
./scripts/new-customer-key.sh fw "PC Engines" "4.16"
```

Script automatically signs newly generated key. Firmware keys are signed with
`ABE1D0BC66278008 2022-01-12  3mdeb Dasharo Master Key` and software keys are
signed with `80693E028589B763 2021-06-23  3mdeb Open Source Software Master Key
<contact@3mdeb.com>`
