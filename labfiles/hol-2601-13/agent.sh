#!/bin/bash

# Usage: sudo ./setup_wheel_sudo.sh <username>

set -e

USER="$1"

if [[ -z "$USER" ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

# Check if user exists
if ! id "$USER" &>/dev/null; then
  echo "User '$USER' does not exist."
  exit 2
fi

# Create wheel group if it doesn't exist
if ! getent group wheel > /dev/null; then
  echo "🔧 Creating 'wheel' group..."
  groupadd wheel
else
  echo "'wheel' group already exists."
fi

# Add user to wheel group
echo "🔧 Adding user '$USER' to 'wheel' group..."
usermod -aG wheel "$USER"

# Configure sudoers (safe via sudoers.d)
SUDOERS_FILE="/etc/sudoers.d/wheel-nopasswd"

if [ -f ]
echo "🔧 Creating sudoers entry at $SUDOERS_FILE..."
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

echo "User '$USER' can now use sudo without password via 'wheel' group."