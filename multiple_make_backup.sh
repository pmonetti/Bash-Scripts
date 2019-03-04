#! /bin/bash

# The utils.sh script is required to use the following functions:
# print_in_green
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_help()
{
  echo "Usage: ./multiple_make_backup.sh <DIR_WITH_DIRS_TO_BACKUP> <PASSWORD> <BACKUP_INFO_DIR_PATH>"
  echo "   where <DIR_WITH_DIRS_TO_BACKUP> and <BACKUP_INFO_DIR_PATH> can be absolute or relative to the current directory."
}

if [ "$#" -ne 3 ] ; then
    print_help
    exit 1
fi

CURRENT_DIR_PATH=${PWD}
DIR_WITH_DIRS_TO_BACKUP=$1
PASS="$2"
BACKUP_INFO_DIR_PATH="$3"

# Check if DIR_WITH_DIRS_TO_BACKUP is a valid directory and go back to the original directory
cd "$DIR_WITH_DIRS_TO_BACKUP" || exit 1
cd "$CURRENT_DIR_PATH"

while read SUBDIRPATH; do
  print_in_green "--- $SUBDIRPATH ---"
  $SCRIPT_DIR/make_backup.sh "$SUBDIRPATH" "$PASS" "$BACKUP_INFO_DIR_PATH" || exit 1
  echo
done < <(find "$DIR_WITH_DIRS_TO_BACKUP" -mindepth 1 -maxdepth 1 -type d)

echo "Calculating md5sums for all packages.."
cd "$CURRENT_DIR_PATH"
MD5SUMS_FILE_PATH="$BACKUP_INFO_DIR_PATH"/md5sum_all.txt
md5sum *.zip > "$MD5SUMS_FILE_PATH"

echo "Extracting file metadata for all packages.."
LS_FILE_PATH="$BACKUP_INFO_DIR_PATH"/ls_all.txt
ls -l *.zip > "$LS_FILE_PATH"
