#!/bin/bashOOOoO

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if filename is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <user-data-file>"
  exit 1
fi

# Variables
user_data_file="$1"
log_file="/var/log/user_management.log"
password_file="/var/secure/user_passwords.txt"

# Create necessary directories and set permissions
mkdir -p /var/secure
chmod 700 /var/secure

# Clear or create log and password files
> $log_file
> $password_file
chmod 600 $password_file

# Function to create a random password
generate_password() {
  openssl rand -base64 12
}

# Read user data file and process each line
while IFS=";" read -r username groups; do
  # Remove leading/trailing whitespaces
  username=$(echo $username | xargs)
  groups=$(echo $groups | xargs)

  # Check if user already exists
  if id "$username" &>/dev/null; then
    echo "User $username already exists." | tee -a $log_file
    continue
  fi

  # Create user with home directory
  useradd -m -s /bin/bash $username
  if [ $? -ne 0 ]; then
    echo "Failed to create user $username." | tee -a $log_file
    continue
  fi

  # Create a personal group for the user
  usermod -aG $username $username

  # Add user to additional groups
  if [ -n "$groups" ]; then
    IFS=',' read -ra group_list <<< "$groups"
    for group in "${group_list[@]}"; do
      group=$(echo $group | xargs)
      if ! getent group $group &>/dev/null; then
        groupadd $group
      fi
      usermod -aG $group $username
    done
  fi

  # Set up home directory permissions
  chmod 755 /home/$username
  chown $username:$username /home/$username

  # Generate and set random password
  password=$(generate_password)
  echo "$username:$password" | chpasswd
  echo "$username,$password" >> $password_file

  # Log actions
  echo "Created user $username with groups $groups" | tee -a $log_file
done < "$user_data_file"

echo "User creation process completed." | tee -a $log_file
