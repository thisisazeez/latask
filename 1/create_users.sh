#!/bin/bash

set -euo pipefail

GROUP_NAME="devteam"
USERS=("sherif1" "sherif2" "sherif3" "sherif4" "sherif5")
DEFAULT_PASSWORD="Sherif@123!"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
        exit 1
    fi
}

create_group() {
    log "Checking if group '$GROUP_NAME' exists..."
    
    if getent group "$GROUP_NAME" >/dev/null 2>&1; then
        success "Group '$GROUP_NAME' already exists"
    else
        log "Creating group '$GROUP_NAME'..."
        if groupadd "$GROUP_NAME"; then
            success "Group '$GROUP_NAME' created successfully"
        else
            error "Failed to create group '$GROUP_NAME'"
            exit 1
        fi
    fi
}

create_user() {
    local username="$1"
    
    log "Processing user '$username'..."
    
    if id "$username" >/dev/null 2>&1; then
        warning "User '$username' already exists, skipping creation"
        
        if groups "$username" | grep -q "$GROUP_NAME"; then
            log "User '$username' is already a member of '$GROUP_NAME'"
        else
            log "Adding existing user '$username' to group '$GROUP_NAME'..."
            usermod -a -G "$GROUP_NAME" "$username"
            success "Added '$username' to group '$GROUP_NAME'"
        fi
        return
    fi

    log "Creating user '$username'..."
    if useradd -m -s /bin/bash -G "$GROUP_NAME" "$username"; then
        success "User '$username' created successfully"
    else
        error "Failed to create user '$username'"
        return 1
    fi

    log "Setting password for user '$username'..."
    if echo "$username:$DEFAULT_PASSWORD" | chpasswd; then
        success "Password set for user '$username'"
    else
        error "Failed to set password for user '$username'"
        return 1
    fi

    log "Forcing password change on first login for '$username'..."
    if chage -d 0 "$username"; then
        success "Password expiry set for user '$username'"
    else
        error "Failed to set password expiry for user '$username'"
        return 1
    fi

    chmod 750 "/home/$username"
    chown "$username:$username" "/home/$username"
    
    success "User '$username' setup completed"
}

show_user_info() {
    log "Displaying user information..."
    echo
    echo "=== USER INFORMATION ==="
    
    for user in "${USERS[@]}"; do
        if id "$user" >/dev/null 2>&1; then
            echo "User: $user"
            echo "  UID: $(id -u "$user")"
            echo "  GID: $(id -g "$user")"
            echo "  Groups: $(groups "$user" | cut -d: -f2)"
            echo "  Home: $(eval echo "~$user")"
            echo "  Shell: $(getent passwd "$user" | cut -d: -f7)"
            echo "  Password Status: $(passwd -S "$user" 2>/dev/null | awk '{print $2}')"
            echo
        fi
    done
    
    echo "=== GROUP INFORMATION ==="
    echo "Group: $GROUP_NAME"
    echo "  GID: $(getent group "$GROUP_NAME" | cut -d: -f3)"
    echo "  Members: $(getent group "$GROUP_NAME" | cut -d: -f4)"
    echo
}

main() {
    log "Starting user management script..."
    echo "This script will create ${#USERS[@]} users and add them to the '$GROUP_NAME' group"
    echo "Default password: $DEFAULT_PASSWORD"
    echo "Users will be forced to change password on first login"
    echo
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Operation cancelled by user"
        exit 0
    fi
    
    check_root
    
    create_group
    

    log "Creating users..."
    for user in "${USERS[@]}"; do
        create_user "$user"
        echo
    done
    
    show_user_info
    
    success "All operations completed successfully!"
    echo
    echo "=== NEXT STEPS ==="
    echo "1. Users can now log in with username and password: $DEFAULT_PASSWORD"
    echo "2. They will be prompted to change their password on first login"
    echo "3. All users are members of the '$GROUP_NAME' group"
    echo "4. Consider setting up SSH keys for secure access"
}
main "$@"