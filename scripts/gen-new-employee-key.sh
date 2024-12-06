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

# List existing key IDs before generating the new key
gpg --list-keys --keyid-format LONG | grep 'pub' | awk '{print $2}' | cut -d'/' -f2 > keys_before.txt

# Generate the key
gpg --batch --generate-key temp_batch_file.txt

# List key IDs after generating the new key
gpg --list-keys --keyid-format LONG | grep 'pub' | awk '{print $2}' | cut -d'/' -f2 > keys_after.txt

# Find the new key ID
KEY_ID=$(comm -13 keys_before.txt keys_after.txt | awk 'NF')

# Clean up temporary files
rm keys_before.txt keys_after.txt

# Check if the key exists using the fingerprint command
if gpg --fingerprint $KEY_ID > /dev/null 2>&1; then
    echo "Key with ID $KEY_ID generated successfully."
else
    echo 'Error: Could not retrieve KEY_ID or key was not generated.'
    exit 1
fi

# Change expire date for KEY_ID signing subkey
# Debugging:
# gpg --command-fd 0 --status-fd 2 --edit-key "$KEY_ID" <<EOF
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
