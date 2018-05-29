#/bin/bash

# utils.sh script is required
# to use the print_and_exec function
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_and_exec "sudo fdisk -l"
print_and_exec "sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL"
print_and_exec "sudo df -h"
