#!/usr/bin/env bash

function usage {
    echo "Usage: $0 [sw|fw|dsw|pce|dasharo] name version"
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
    echo -e "\t Examples:"
    echo -e "\t \t $0 sw \"FooBar\" \"0.1\""
    echo -e "\t \t $0 fw \"FooBar\" \"4.2\""
    echo -e "\t \t $0 dsw \"Dasharo Tools Suite\" \"1.0.x\""
    echo -e "\t \t $0 pce \"PC Engines\" \"4.16\""
    echo -e "\t \t $0 compat \"MSI MS-7D25\" \"0.x\""
    echo -e "\t \t $0 dasharo \"Protectli\" \"1.1.x\""
    exit 1
}


[ $# -ne 3 ] && echo "ERROR: invalid number of parameters" && usage && exit 1
[ -z "$2" ] && echo "ERROR: name is null" && exit 1
[ -z "$3" ] && echo "ERROR: version is null" && exit 1
subcmd=$1
name=$2
version=$3

case $subcmd in
    sw)
	real_name="${name} open-source software release ${version} signing key"
	# 3mdeb Open Source Software Master Key <contact@3mdeb.com>
	signing_kid=6058A306EF96BCBF56567B8C80693E028589B763
	;;
    fw)
	real_name="${name} open-source firmware release ${version} signing key"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
    dsw)
	real_name="${name} open-source software release ${version} signing key"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
    compat)
	real_name="Dasharo release ${version} compatible with ${name} signing key"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
    dasharo)
	real_name="Dasharo release ${version} for ${name} signing key"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
    pce)
	real_name="PC Engines open-source firmware release ${version} signing key"
	# 3mdeb Open Source Firmware Master Key <contact@3mdeb.com>
	signing_kid=EA61CBADDA1C094A2540E596028A752764CB97EC
	;;
    *)
	echo "ERROR: $subcmd is not a known subcommand."
	usage
	exit 1
	;;
esac

# chek if such key already exist
gpg --with-colons --list-key "${real_name}" 2> /dev/null
if [ $? -eq 0 ]; then
    echo "ERROR: Key ${real_name} already exist."
    exit 1
fi

sed -e "s/{real_name}/${real_name}/g" ./scripts/new_key_gpg.template > /tmp/gpg_batch
gpg --batch --gen-key /tmp/gpg_batch
new_kid=$(gpg --with-colons --list-key "${real_name}"|awk -F: '$1 == "fpr" {print $10;}'|head -1)
tmp=${real_name// /-}
keyname=${tmp,,}
if [ -f ${keyname}-priv.asc ]; then
    echo "ERROR: ${keyname}-priv.asc already exist."
    exit 1
fi
gpg -u $signing_kid --sign-key $new_kid
gpg --armor --export-secret-keys $new_kid > ${keyname}-priv.asc
echo "Private key successfully exported"
