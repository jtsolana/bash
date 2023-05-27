#!/bin/bash

# Script: create_user.sh
# This script allows the root user to create a new user account on a Linux system.
# It prompts for a new username and password, checks if the user already exists,
# creates the user, sets the password, and displays the new username, password, and hostname.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Get user input for new username and password
read -p "Enter a username for the new user: " newusername

# check if user already exists
if id "$newusername" >/dev/null 2>&1; then
    echo "User $newusername already exists"
    exit 1
fi

read -sp "Enter a password for the new user: " newpassword

# Create the new user and set the password
if useradd -m $newusername; then
  echo "$newusername:$newpassword" | chpasswd
  # Display the new username, password, and hostname
  echo "New user $newusername with password $newpassword has been created on $(hostname)"
else
  echo "Failed to create user $newusername"
  exit 1
fi