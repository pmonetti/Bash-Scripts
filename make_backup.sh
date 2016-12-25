#/bin/bash

print_help()
{
  echo "Usage: ./make_backup.sh <DIR_TO_PACKAGE> <PASSWORD> <BACKUP_INFO_DIR>"
}

is_relative_path()
{
    INPUT_PATH="$1"
    if [[ "$INPUT_PATH" = /* ]]; then
        return 1    # false = 1
    else
        return 0    # true = 0
    fi
}

if [ "$#" -ne 3 ] ; then
    print_help
    exit 1
fi

DIRPATH="$1"
BACKUP_INFO_DIR="$3"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if DIRPATH is a valid directory
cd "$DIRPATH" || { echo 'ERROR: '"$DIRPATH"' is not a directory'; exit 1; }
cd --                                   # Go back to the original directory
# Make DIRPATH an absolute path
if is_relative_path "$DIRPATH" ; then
    CURRENT_DIR=${PWD}
    DIRPATH="$CURRENT_DIR"/"$DIRPATH"
fi

# Check if BACKUP_INFO_DIR is a valid directory
cd "$BACKUP_INFO_DIR" || { echo 'ERROR: '"$BACKUP_INFO_DIR"' is not a directory'; exit 1; }
cd --                                   # Go back to the original directory
# Make BACKUP_INFO_DIR an absolute path
if is_relative_path "$BACKUP_INFO_DIR" ; then
    CURRENT_DIR=${PWD}
    BACKUP_INFO_DIR="$CURRENT_DIR"/"$BACKUP_INFO_DIR"
fi

BACKUP_INFO_DIR=${BACKUP_INFO_DIR%/}    # Remove trailing slashes if exists
DIRPATH=${DIRPATH%/}                    # Remove trailing slashes if exists
DIRNAME="${DIRPATH##*/}"
ZIPFILE_NAME="$DIRNAME".zip

"$SCRIPT_DIR"/dir_analyzer.sh "$DIRPATH" > "$BACKUP_INFO_DIR"/"$DIRNAME"_analysis.txt
cp -r /tmp/dir_analysis/ "$BACKUP_INFO_DIR"/"$DIRNAME"_analysis/

tree -a "$DIRPATH" > "$BACKUP_INFO_DIR"/"$DIRNAME"_tree.txt

TARNAME="$DIRNAME".tar

tar -czvf "$TARNAME" "$DIRPATH"/* && zip -r "$ZIPFILE_NAME" --password "$2" "$TARNAME"
mv "$ZIPFILE_NAME" "$DIRPATH"/"$ZIPFILE_NAME"
rm "$TARNAME"
