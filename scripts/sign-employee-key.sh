#!/usr/bin/env bash

# Check if a key file is provided as an argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <key_file>"
  exit 1
fi

key_file="$1"

if [ ! -f "$key_file" ]; then
  echo "File: $key_file does not exist"
  echo "Usage: $0 <key_file>"
  exit 1
fi

# Function to prompt for confirmation with 'y' or 'n'
confirm() {
  read -r -p "$1 [y/N]: " response
  case "$response" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Extract the employee email address from the key file
employee_email=$(gpg -n -q --import --import-options import-show "$key_file" 2>&1 | grep -oP "(?<=<).+@.+(?=>)")
if [ -z "$employee_email" ]; then
  echo "Failed to extract email address from the key file. Please check the format."
  exit 1
fi

echo "Employee name extracted from the key: $employee_email"
echo

echo "Cross-verify fingerprint received via another channel:"
# Show fingerprint
gpg -n -q --import --import-options import-show "$key_file"
echo

# Ask for confirmation to import keyw
if ! confirm "Do you want to proceed by importing key?"; then
  echo "Key signing process aborted."
  exit 0
fi

# Import the key
echo "Importing the key:"
gpg --import "$key_file"
echo

# Check signatures before signing
echo "Checking signatures before signing:"
gpg --check-sigs "$employee_email"
echo

# Extract your default key's email address
your_key_email=$(gpg --list-keys --with-colons | awk -F: '/^uid/{print $10; exit}')
if [ -z "$your_key_email" ]; then
  echo "Failed to extract your default GPG key email address. Make sure you have a default key configured."
  exit 1
fi
echo "Following user will be used for signing: $your_key_email"
echo

# Prompt for confirmation to sign the key
if ! confirm "Do you want to sign this key?"; then
  echo "Key signing process aborted."
  exit 0
fi

# Sign the key using your default key
echo "Signing the key:"
gpg -u "$your_key_email" --sign-key "$employee_email"
echo

# Check signatures after signing
echo "Checking signatures after signing:"
gpg --check-sigs "$employee_email"
echo

# Set the signed key file dynamically based on the input file name
signed_key_file="${key_file%.asc}-signed.asc"
echo "Exporting the signed key to $signed_key_file:"
gpg --armor --output "$signed_key_file" --export "$employee_email"
