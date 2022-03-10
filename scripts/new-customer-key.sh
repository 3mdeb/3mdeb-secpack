#!/bin/bash

function usage {
    echo "Usage: $0 [sw|fw|pce] customer_name version"
    echo -e "\t [sw|fw|pce] - determine signin key and real name format."
    echo -e "\t \t sw - real name 'open-source software', signed with 3mdeb Open Source Software Master Key <contact@3mdeb.com>"
    echo -e "\t \t fw - real name 'open-source firmware', signed with 3mdeb Dasharo Master Key"
    echo -e "\t \t pce - real name 'PC Engines open-source firmware', signed with 3mdeb Open Source Firmware Master Key <contact@3mdeb.com>"
    echo -e "\t customer_name - customer name in quotes e.g. \"PC Engines\", if customer_name directory does not exist it would be created"
    echo -e "\t version - version e.g. \"4.16\", \"1.x\", if version exist error would be returned"
    echo -e "\t Examples:"
    echo -e "\t \t $0 sw \"FooBar\" \"0.1\""
    echo -e "\t \t $0 fw \"FooBar\" \"4.2\""
    echo -e "\t \t $0 pce \"DoesNotMatter\" \"4.16\""
    exit 1
}


[ $# -ne 3 ] && echo "ERROR: invalid number of parameters" && usage && exit 1
[ -z "$2" ] && echo "ERROR: customer_name is null" && exit 1
[ -z "$3" ] && echo "ERROR: version is null" && exit 1
subcmd=$1
customer_name=$2
version=$3

case $subcmd in
    sw)
	real_name="${customer_name} open-source software release ${version} signing key"
	# 3mdeb Open Source Software Master Key <contact@3mdeb.com>
	signing_kid=6058A306EF96BCBF56567B8C80693E028589B763
	;;
    fw)
	real_name="${customer_name} open-source firmware release ${version} signing key"
	# 3mdeb Dasharo Master Key
	signing_kid=0D5F6F1DA800329EB7C597A2ABE1D0BC66278008
	;;
    pce)
	real_name="PC Engines open-source firmware release ${version} signing key"
	# 3mdeb Open Source Software Master Key <contact@3mdeb.com>
	signing_kid=6058A306EF96BCBF56567B8C80693E028589B763
	;;
    *)
	echo "ERROR: $subcmd is not a known subcommand."
	usage
	exit 1
	;;
esac

# chek if such key already exist
gpg --with-colons --list-key "${real_name}" 
if [ $? -eq 0 ]; then
    echo "ERROR: Key ${real_name} already exist."
    exit 1
fi

sed -e "s/{customer_name}/${customer_name}/g" -e "s/{version}/${version}/g" ./scripts/new_key_gpg.template > /tmp/gpg_batch
gpg --batch --gen-key /tmp/gpg_batch
new_kid=$(gpg --with-colons --list-key "${real_name}"|awk -F: '$1 == "fpr" {print $10;}')
tmp=${real_name// /-}
keyname=${tmp,,}
if [ -f ${keyname}-priv.asc ]; then
    echo "ERROR: ${keyname}-priv.asc already exist."
    exit 1
fi
gpg -u $signing_kid --sign-key $new_kid
gpg --armor --export-secret-keys $new_kid > ${keyname}-priv.asc
echo "Private key successfully exported"
