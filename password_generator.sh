#!/bin/bash
# This Script Generate a random password with 8 character and at least one special character.
# Simply modify the head -c8 to generate the desired number of characters.

# Define an array of special characters
special_chars=("!" "#" "$" "%" "&" "@")

# Generate a random password
password=$(date +%s%N | sha256sum | head -c8)

# Choose a random special character from the array
random_char=${special_chars[$((RANDOM % ${#special_chars[@]}))]}

# Insert the random special character into the password
password="${password:0:1}${random_char}${password:1}"

echo $password