#!/bin/bash

# Define log file and password storage file
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Create the directory for secure password storage if it doesn't exist
mkdir -p /var/secure
# Ensure the password file is only accessible by root
touch $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

# Function to create a user with a random password
create_user() {
  local username=$1
  local groups=$2

  # Create a personal group for the user
  if ! grep -q "^$username:" /etc/group; then
    groupadd "$username"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Group $username created" >> $LOG_FILE
  fi

  # Create the user with their personal group
  if ! id "$username" &>/dev/null; then
    useradd -m -g "$username" -s /bin/bash "$username"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - User $username created" >> $LOG_FILE
  fi

  # Generate a random password
  local password=$(openssl rand -base64 12)
  echo "$username:$password" | chpasswd
  echo "$username:$password" >> $PASSWORD_FILE
  echo "$(date +'%Y-%m-%d %H:%M:%S') - Password for $username generated and stored securely" >> $LOG_FILE

  # Assign additional groups to the user
  if [ -n "$groups" ]; then
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
      if ! grep -q "^$group:" /etc/group; then
        groupadd "$group"
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Group $group created" >> $LOG_FILE
      fi
      usermod -aG "$group" "$username"
      echo "$(date +'%Y-%m-%d %H:%M:%S') - User $username added to group $group" >> $LOG_FILE
    done
  fi
}

# User and group data
declare -A user_groups=(
  [olopade]="sudo,dev,www-data"
  [ezekiel]="sudo"
  [oladimeji]="dev,www-data"
)

# Iterate over the user_groups associative array
for username in "${!user_groups[@]}"; do
  create_user "$username" "${user_groups[$username]}"
done

echo "User creation process completed. Check $LOG_FILE for details."
