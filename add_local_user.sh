#!/bin/bash
# This script adds users to the same linux system as the script is executed on.
# The username, password, and host for the account will be displayed after a sucessful run. 

# Make sure the script is being executed with superuser privileges.
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Get the username (login).
read -p 'Enter the username to create: ' username

# check if user already exists
if id "$username" >/dev/null 2>&1; then
    echo "user $username already exists"
    exit 1
fi

# Get the real name (contents for the description field).
read -p 'Enter the fullname of the person who this account is for: ' fullname

# Get the password.
read -sp 'Enter the password to use for the account: ' password

# Create the user account with the password.
useradd -c "${fullname}" -m ${username}
echo "$username:$password" | chpasswd

# Force password change on first login.
passwd -e ${username}

# Display the username, password, and the host where the user was created.
echo "username:"
echo ${username}

echo "password:"
echo ${password}

echo "host:"
echo $(hostname)

