#!/bin/bash

# monitor_disk_space.sh

# Set the threshold for disk space usage (in percentage)
threshold=30

# Set the email address to receive notifications
email_address="sample@email.com"

# Get disk usage information using df, and filter the output to get the usage percentage
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)

# Check if disk usage exceeds the threshold
if [ "$disk_usage" -ge "$threshold" ]; then
    # Compose the email message with the subject included in the body
    email_subject="Disk Space Alert"
    email_body="Subject: $email_subject\n\nWarning: Disk space usage is at $disk_usage%. Please check and free up space."

    # Send the email using postfix's sendmail command
    echo -e "$email_body" | /usr/sbin/sendmail "$email_address"
fi