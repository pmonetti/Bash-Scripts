#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_and_exec "inxi -ABDGS"
print_and_exec "uname -r"
print_and_exec "lsb_release -a"
print_and_exec "lscpu"
