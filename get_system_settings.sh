#/bin/bash

# The utils.sh script is required to use the following functions:
# print_and_exec
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_and_exec "inxi -ADGS"
print_and_exec "uname -r"
print_and_exec "lsb_release -a"
print_and_exec "lscpu"
