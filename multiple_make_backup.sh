#/bin/bash

print_help()
{
  echo "Usage: ./multiple_make_backup.sh <DIR_WITH_DIRS_TO_BACKUP> <PASSWORD> <BACKUP_INFO_DIR_PATH>"
  echo "   where <DIR_WITH_DIRS_TO_BACKUP> and <BACKUP_INFO_DIR_PATH> can be absolute or relative to the current directory."
}

if [ "$#" -ne 3 ] ; then
    print_help
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR_PATH=${PWD}
DIR_WITH_DIRS_TO_BACKUP=$1
PASS=$2

# Check if DIR_WITH_DIRS_TO_BACKUP is a valid directory and go back to the original directory
cd "$DIR_WITH_DIRS_TO_BACKUP" || { echo 'ERROR: '"$DIR_WITH_DIRS_TO_BACKUP"' is not a directory'; exit 1; }
cd "$CURRENT_DIR_PATH"

while read SUBDIRPATH; do
  $SCRIPT_DIR/make_backup.sh "$SUBDIRPATH" $2 $3
done < <(find "$DIR_WITH_DIRS_TO_BACKUP" -mindepth 1 -maxdepth 1 -type d)
