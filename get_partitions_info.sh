#/bin/bash

sudo fdisk -l
sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
sudo df -h
