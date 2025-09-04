# Script Explanation
## Configuration Section


```bash
GROUP_NAME="devteam"
USERS=("sherif1" "sherif2" "sherif3" "sherif4" "sherif5")
DEFAULT_PASSWORD="TempPass123!"
```


### Functions
check_root()
* Validates that the script is run with root privileges

create_group()
* Checks if the target group exists using getent group
* Creates the group if it doesn't exist using groupadd

create_user()
* Handles individual user creation with error checking
* Uses useradd -m -s /bin/bash -G for proper user setup
* Sets passwords using chpasswd
* Forces password change using chage -d 0

show_user_info()
* Displays comprehensive information about created users
* Shows UID, GID, groups, home directory, shell, and password status
Usage Instructions
Prerequisites
* Root access (run with sudo)
* Standard Linux system with user management tools

## Running the Script
```bash

curl -O https://raw.githubusercontent.com/thisisazeez/latask/refs/heads/develop/1/create_users.sh

chmod +x create_users.sh

sudo ./create_users.sh
```