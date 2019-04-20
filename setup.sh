#! /bin/bash

GOOGLE_INSTALLER_PATH=~/google-chrome-stable_current_amd64.deb

# Validate that Google Chrome installer exists
ls $GOOGLE_INSTALLER_PATH || exit 1

# Install packages
sudo apt-get update || exit 1

sudo apt-get install -y \
						yakuake geany htop \
						tree gparted baobab \
						git kompare curl\
						vlc \
						openvpn \
						virtualbox \
						|| exit 1
						
sudo snap install spotify || exit 1

sudo dpkg -i $GOOGLE_INSTALLER_PATH || exit 1
sudo apt-get install -f -y || exit 1

# Clone bash scripts if they are not available
if [ ! -f ~/Bash-Scripts/setup.sh ]; then
    git clone https://github.com/pmonetti/Bash-Scripts.git || exit 1
fi

# Upgrade system and clean
~/Bash-Scripts/update_linux.sh || exit 1

# Load XFCE panel
~/Bash-Scripts/load_xfce_panel.sh || exit 1
