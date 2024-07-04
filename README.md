This script automates the process of creating users on a Unix/Linux system. It generates a unique user for each entry defined within the script, assigns them to specified groups, creates a secure password for each user, and logs the process. Additionally, it securely stores the generated passwords in a designated file.


Features
User Creation: Automatically creates users with a home directory and a default shell.
Group Management: Assigns users to existing groups or creates new groups as necessary.
Password Generation: Generates secure, random passwords for each user.
Logging: Logs all actions taken by the script, including user and group creation.
Secure Password Storage: Stores generated passwords in a secure file with restricted access.


Prerequisites
A Unix/Linux system
Root or sudo privileges
OpenSSL installed for password generation

Installation
1.Download the Script: Save the script to your preferred location on your Unix/Linux system.

2. Make the Script Executable:
chmod +x create_users.sh

Usage
1.Open Terminal: Navigate to the directory where the script is located.

2.Run the Script as Root:

sudo ./create_users.sh

File Descriptions
create_users.sh: The main script file that contains all the logic for user creation, group assignment, password generation, and logging.

/var/log/user_management.log: Log file where the script outputs its actions, including user and group creation details.

/var/secure/user_passwords.txt: Secure file where generated passwords are stored. This file is readable and writable only by the root user.

Security
The script ensures that the password file (/var/secure/user_passwords.txt) is only accessible by the root user, protecting sensitive information.
Passwords are generated using OpenSSL, providing strong, random passwords for each user.




