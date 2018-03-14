#!/bin/sh

# Add the Spotify repository signing key to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

# Install packages
sudo apt-get update
sudo apt-get install -y yakuake htop tree
sudo apt-get install -y synaptic dconf-tools gksu gdebi inxi leafpad catfish pavucontrol 
sudo apt-get install -y xubuntu-restricted-extras libdvd-pkg
sudo apt-get install -y git geany openvpn
sudo apt-get install -y libgconf2-4 libnss3-1d libxss1
sudo apt-get install -y spotify-client

sudo dpkg -i ~/Downloads/google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y

# Upgrade system and clean
git clone https://github.com/pmonetti/Bash-Scripts.git
~/Bash-Scripts/update_linux.sh

# Add yakuake to startup
mkdir -p ~/.config/autostart/
cat << EOF >> ~/.config/autostart/yakuake.desktop
[Desktop Entry]
Type=Application
Exec=/usr/bin/yakuake
Name=yakuake
Comment=yakuake 
EOF
