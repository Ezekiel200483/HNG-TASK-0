#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <name-of-text-file>"
    exit 1
fi

INPUT_FILE="$1"
LOG_FILE="./user_management.log"
PASSWORD_FILE="./user_passwords.csv"

# Create the log and password files if they don't exist
touch $LOG_FILE
touch $PASSWORD_FILE

# Log the start time
echo "$(date) - Starting user creation process with input file: $INPUT_FILE" >> $LOG_FILE

# Read the input file line by line
while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs) # Trim any leading/trailing whitespace
    groups=$(echo "$groups" | xargs)     # Trim any leading/trailing whitespace

    echo "$(date) - Processing user: $username with groups: $groups" >> $LOG_FILE

    # Check if the user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "$(date) - User $username already exists." >> $LOG_FILE
        continue
    fi

    # Create the user and their personal group
    if useradd -m -s /bin/bash "$username"; then
        echo "$(date) - User $username created." >> $LOG_FILE
    else
        echo "$(date) - Failed to create user $username." >> $LOG_FILE
        continue
    fi

    # Set a random password for the user
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    echo "$(date) - Password set for user $username." >> $LOG_FILE

    # Store the username and password in the password file
    echo "$username,$password" >> $PASSWORD_FILE

    # Set ownership and permissions for the password file
    chmod 600 $PASSWORD_FILE
    chown root:root $PASSWORD_FILE

    # Add user to the specified groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo "$group" | xargs) # Trim any leading/trailing whitespace
        if ! getent group "$group" >/dev/null 2>&1; then
            groupadd "$group"
            echo "$(date) - Group $group created." >> $LOG_FILE
        fi
        usermod -aG "$group" "$username"
        echo "$(date) - User $username added to group $group." >> $LOG_FILE
    done
done < "$INPUT_FILE"

# Log the completion time
echo "$(date) - User creation and group assignment complete." >> $LOG_FILE

# Output the log and password file paths
echo "User creation and group assignment complete. Check $LOG_FILE for details."
echo "User passwords stored in $PASSWORD_FILE."
