#/bin/bash

print_and_exec()
{
	CMD="$1"
	RED='\033[0;31m'
	NO_COLOR='\033[0m'	
	printf "${RED}${CMD}${NO_COLOR}\n"
	eval $CMD
	echo
}
