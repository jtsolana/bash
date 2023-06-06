#!/bin/bash

# Function to display error messages
print_error() {
  echo "Error: $1" >&2
}

# Function to display usage information
display_usage() {
  echo "Usage: $0 [-d] [-r] [-a] <username>..." >&2
  echo "Options:"
  echo "  -d: Delete user account"
  echo "  -r: Remove home directory"
  echo "  -a: Create archive of home directory"
}

# Check if the script is executed with superuser (root) privileges
if [[ "$(id -u)" -ne 0 ]]; then
  print_error "This script must be executed with superuser privileges."
  display_usage
  exit 1
fi

# Parse options
while getopts ":dra" opt; do
  case $opt in
    d) delete_account=1 ;;
    r) remove_home=1 ;;
    a) create_archive=1 ;;
    :) print_error "Option -$OPTARG requires an argument."
       display_usage
       exit 1 ;;
    \?) print_error "Invalid option: -$OPTARG"
        display_usage
        exit 1 ;;
  esac
done

# Shift the option parameters
shift $((OPTIND - 1))

# Check if at least one username is provided
if [[ $# -eq 0 ]]; then
  print_error "At least one username must be provided."
  display_usage
  exit 1
fi

# Loop through all the usernames supplied as arguments
for username in "$@"; do
  # Make sure the UID of the account is at least 1000
  uid=$(id -u "$username")
  if [[ $uid -lt 1000 ]]; then
    print_error "Refusing to modify system account '$username'."
    continue
  fi

  # Create an archive if requested
  if [[ $create_archive -eq 1 ]]; then
    archive_dir="/archives"
    if ! [[ -d "$archive_dir" ]]; then
      mkdir -p "$archive_dir" &>/dev/null
      if [[ $? -ne 0 ]]; then
        print_error "Failed to create archive directory."
        exit 1
      fi
    fi
    if [[ -d "/home/$username" ]]; then
      tar -czf "$archive_dir/$username.tar.gz" "/home/$username" &>/dev/null
      if [[ $? -ne 0 ]]; then
        print_error "Failed to create archive for user '$username'."
        exit 1
      fi
    fi
  fi

  # Delete the user if requested
  if [[ $delete_account -eq 1 ]]; then
    userdel "$username" &>/dev/null
    if [[ $? -ne 0 ]]; then
      print_error "Failed to delete user '$username'."
      exit 1
    fi
  fi

  # Disable the user if not deleted
  if [[ $delete_account -ne 1 ]]; then
    passwd -l "$username" &>/dev/null
    if [[ $? -ne 0 ]]; then
      print_error "Failed to disable user '$username'."
      exit 1
    fi
  fi

  # Display the username and actions performed
  actions=""
  if [[ $delete_account -eq 1 ]]; then
    actions+="Deleted "
  else
    actions+="Disabled "
  fi
  if [[ $create_archive -eq 1 ]]; then
    actions+="(Archived) "
  fi
  echo "$username: $actions"

done
