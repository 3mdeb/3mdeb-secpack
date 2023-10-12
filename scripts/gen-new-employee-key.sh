#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <KEY_NAME> <KEY_EMAIL>"
    exit 1
fi

# Variables from command line
KEY_NAME="$1"
KEY_EMAIL="$2"
KEY_COMMENT="Employee Cert Key"
KEY_FILE="$KEY_EMAIL.asc"

# Batch file content for key generation
BATCH_FILE_CONTENT=$(cat <<EOF
%echo Generating a primary certification key and subkeys for signing and encryption
Key-Type: RSA
Key-Length: 4096
Key-Usage: cert
Expire-Date: 0
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: sign
Name-Real: $KEY_NAME
Name-Comment: $KEY_COMMENT
Name-Email: $KEY_EMAIL
%no-protection
%commit
%echo Key generation complete
EOF
)

# Write the batch file content to a temporary file
echo "$BATCH_FILE_CONTENT" > temp_batch_file.txt

# Retrieve the KEY_ID of the recently generated key
KEY_ID=$(gpg --batch --generate-key temp_batch_file.txt 2>&1 | grep "gpg: key" | awk '{print $3}')

# Check if KEY_ID was retrieved
if [ -z "$KEY_ID" ]; then
    echo "Error: Could not retrieve KEY_ID."
    exit 1
else
    echo "Modifying key: $KEY_ID"
fi

# Change expire date for KEY_ID signing subkey
# Debugging: gpg --command-fd 0 --status-fd 2 --edit-key "$KEY_ID" <<EOF
gpg --command-fd 0 --edit-key "$KEY_ID" <<EOF
key 1
expire
1y
save
EOF

if [ $? -ne 0 ]; then
    echo "Error: Cannot change expiration date for signing subkey."
    exit 1
fi


# Add encryption key
gpg --command-fd 0 --edit-key "$KEY_ID" <<EOF
addkey
6
4096
1y
save
EOF

if [ $? -ne 0 ]; then
    echo "Error: Cannot create encryption subkey."
    exit 1
fi

# Export the public key
gpg --armor --export "$KEY_NAME ($KEY_COMMENT) <$KEY_EMAIL>" > $KEY_FILE

if [ $? -ne 0 ]; then
    echo "Error: Key not found."
    exit 1
fi

# Remove the temporary batch file
rm temp_batch_file.txt
echo "Your KEY_ID: $KEY_ID"
