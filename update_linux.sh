#/bin/bash

sudo apt-get -y update || exit 1
sudo apt-get -y upgrade || exit 1
sudo apt-get -y clean || exit 1
sudo apt-get -f install || exit 1
sudo apt-get -y clean || exit 1
sudo apt-get -y autoclean || exit 1
sudo apt-get -y autoremove || exit 1
sudo apt-get check
