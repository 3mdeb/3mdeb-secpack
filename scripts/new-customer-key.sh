#!/usr/bin/env bash

function usage {
	echo "Usage: $0 [sw|fw|dsw|pce|dasharo] name version [recipient-email]"
	echo -e "\t [sw|fw|dsw|pce|dasharo] - determine signing key and real name format."
	echo -e "\t \t sw - real name '<name> open-source software release <version>', signed with 3mdeb Open Source Software Master Key <contact@3mdeb.com>"
	echo -e "\t \t fw - real name '<name> open-source firmware release <version>', signed with 3mdeb Dasharo Master Key"
	echo -e "\t \t dsw - real name '<name> open-source software release <version>', signed with 3mdeb Dasharo Master Key"
	echo -e "\t \t pce - real name 'PC Engines open-source firmware', signed with 3mdeb Open Source Firmware Master Key <contact@3mdeb.com>"
	echo -e "\t \t dasharo - real name 'Dasharo release <version> for <name>', signed with 3mdeb Dasharo Master Key"
	echo -e "\t \t compat - real name 'Dasharo release <version> compatible with <name>', signed with 3mdeb Dasharo Master Key"
	echo -e "\t name - customer name in quotes e.g. \"PC Engines\", if name directory does not exist it would be created"
	echo -e "\t \t \tor platform name in case of Dasharo firmware produced by 3mdeb."
	echo -e "\t version - version e.g. \"4.16\", \"1.x\", if version exist error would be returned"
	echo -e "\t [recipient-email] - if provided encrypt private key for recipient"
	echo -e "\t Examples:"
	echo -e "\t \t $0 sw \"FooBar\" \"0.1\""
	echo -e "\t \t $0 fw \"FooBar\" \"4.2\""
	echo -e "\t \t $0 dsw \"Dasharo Tools Suite\" \"1.0.x\""
	echo -e "\t \t $0 pce \"PC Engines\" \"4.16\""
	echo -e "\t \t $0 compat \"MSI MS-7D25\" \"0.x\""
	echo -e "\t \t $0 dasharo \"Protectli\" \"1.1.x\""
	echo -e "\t \t $0 dasharo \"FooBar\" \"1.2.x\" \"joe.doe@3mdeb.com\"""
	exit 1
}

[ $# -lt 3 ] || [ $# -gt 4 ] && echo "ERROR: invalid number of parameters" && usage && exit 1
[ -z "$2" ] && echo "ERROR: name is null" && exit 1
[ -z "$3" ] && echo "ERROR: version is null" && exit 1
subcmd=$1
name=$2
version=$3
recipient=$4

case $subcmd in
sw)
	key_name="${name} open-source software release ${version} signing key"
	key_email="contact@3mdeb.com"
	# 3mdeb Open Source Software Master Key <contact@3mdeb.com>
	signing_kid=6058A306EF96BCBF56567B8C80693E028589B763
	;;
fw)
	key_name="${name} open-source firmware release ${version} signing key"
	key_email="contact@dasharo.com"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
dsw)
	key_name="${name} open-source software release ${version} signing key"
	key_email="contact@dasharo.com"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
compat)
	key_name="Dasharo release ${version} compatible with ${name} signing key"
	key_email="contact@dasharo.com"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
dasharo)
	key_name="Dasharo release ${version} for ${name} signing key"
	key_email="contact@dasharo.com"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
pce)
	key_name="PC Engines open-source firmware release ${version} signing key"
	key_email="contact@3mdeb.com"
	# 3mdeb Open Source Firmware Master Key <contact@3mdeb.com>
	signing_kid=EA61CBADDA1C094A2540E596028A752764CB97EC
	;;
*)
	echo "ERROR: $subcmd is not a known subcommand."
	usage
	exit 1
	;;
esac

# check if such key already exist
gpg --with-colons --list-key "${key_name}" 2>/dev/null
if [ $? -eq 0 ]; then
	echo "ERROR: Key ${key_name} already exist."
	exit 1
fi

sed -e "s/{key_name}/${key_name}/g; s/{key_email}/${key_email}/g" ./scripts/new_key_gpg.template >/tmp/gpg_batch
gpg --batch --gen-key /tmp/gpg_batch
new_kid=$(gpg --with-colons --list-key "${key_name}" | awk -F: '$1 == "fpr" {print $10;}' | head -1)
# Change expire date for KEY_ID signing subkey
# Debugging:
# gpg --command-fd 0 --status-fd 2 --edit-key "$KEY_ID" <<EOF
gpg --command-fd 0 --edit-key "${new_kid}" <<EOF
key 1
expire
1y
save
EOF
tmp=${key_name// /-}
keyname=${tmp,,}
if [ -f ${keyname}-priv.asc ]; then
	echo "ERROR: ${keyname}-priv.asc already exist."
	exit 1
fi
gpg -u $signing_kid --sign-key $new_kid
if [ -n "$recipient" ]; then
	gpg --armor --export-secret-keys $new_kid | gpg --encrypt --recipient $recipient >${keyname}-priv.gpg
else
	gpg --armor --export-secret-keys $new_kid >${keyname}-priv.asc
fi
echo "Private key successfully exported"
