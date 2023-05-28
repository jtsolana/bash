#!/bin/bash

# Script: create_user.sh
# This script allows the root user to create a new user account on a Linux system.
# It prompts for a new username and password, checks if the user already exists,
# Creates the user, sets the password, and displays the new username, password, and hostname.

# Function to display error messages
print_error() {
  echo "Error: $1" >&2
}

# Check if the script is executed with superuser (root) privileges
if [[ "$(id -u)" -ne 0 ]]; then
  print_error "This script must be executed with superuser privileges."
  exit 1
fi

# Check if the username is provided as the first argument
if [[ -z "$1" ]]; then
  print_error "Usage: $0 <username> [comment]"
  exit 1
fi

# Assign the username and comment from command line arguments
username="$1"
comment="$2"

# Generate a random password for the new account
password=$(openssl rand -base64 12)

# Create the new user account
if ! sudo useradd -m -c "$comment" "$username" &>/dev/null; then
  print_error "Failed to create the user account."
  exit 1
fi

# Set the generated password for the new user account
echo "$username:$password" | sudo chpasswd &>/dev/null

# Enforce password change on first login
passwd -e ${username}

# Display the account information
echo "User account successfully created:"
echo "Username: $username"
echo "Password: $password"
echo "Host: $(hostname)"
