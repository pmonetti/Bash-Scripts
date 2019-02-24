#/bin/bash

# The utils.sh script is required to use the following functions:
# make_dir_path_absolute
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_help()
{
  echo "Usage: ./make_backup.sh <DIR_TO_PACKAGE_PATH> <PASSWORD> <BACKUP_INFO_DIR_PATH>"
  echo "   where <DIR_TO_PACKAGE_PATH> and <BACKUP_INFO_DIR_PATH> can be absolute or relative to the current directory."
}

if [ "$#" -ne 3 ] ; then
    print_help
    exit 1
fi

DIR_TO_PACKAGE_PATH="$1"
BACKUP_INFO_DIR_PATH="$3"
CURRENT_DIR_PATH=${PWD}

# Check if DIR_TO_PACKAGE_PATH is a valid directory and go back to the original directory
cd "$DIR_TO_PACKAGE_PATH" || { echo 'ERROR: '"$DIR_TO_PACKAGE_PATH"' is not a directory'; exit 1; }
cd "$CURRENT_DIR_PATH"

# Check if BACKUP_INFO_DIR is a valid directory and go back to the original directory
cd "$BACKUP_INFO_DIR_PATH" || { echo 'ERROR: '"$BACKUP_INFO_DIR_PATH"' is not a directory'; exit 1; }
cd "$CURRENT_DIR_PATH"


sudo apt-get install tree

DIR_TO_PACKAGE_PATH=$(make_dir_path_absolute "$DIR_TO_PACKAGE_PATH")
DIR_TO_PACKAGE_PATH=${DIR_TO_PACKAGE_PATH%/}		# Remove trailing slashes if exists
DIR_TO_PACKAGE_NAME=${DIR_TO_PACKAGE_PATH##*/}


# Extract info about files in the directory to package
BACKUP_INFO_DIR_PATH=$(make_dir_path_absolute "$BACKUP_INFO_DIR_PATH")
BACKUP_INFO_DIR_PATH=${BACKUP_INFO_DIR_PATH%/}    	# Remove trailing slashes if exists
SCRIPT_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_INFO_PACKAGE_DIR_PATH="$BACKUP_INFO_DIR_PATH"/"$DIR_TO_PACKAGE_NAME"_analysis/
mkdir "$BACKUP_INFO_PACKAGE_DIR_PATH"
"$SCRIPT_DIR_PATH"/dir_analyzer.sh "$DIR_TO_PACKAGE_PATH" > "$BACKUP_INFO_PACKAGE_DIR_PATH"/"$DIR_TO_PACKAGE_NAME"_analysis.txt
cp -r /tmp/dir_analysis/* "$BACKUP_INFO_PACKAGE_DIR_PATH"
tree -a "$DIR_TO_PACKAGE_PATH" > "$BACKUP_INFO_PACKAGE_DIR_PATH"/"$DIR_TO_PACKAGE_NAME"_tree.txt

# The tar and zip files are built in a neutral directory because, otherwise, the generation will fail 
# when the current directory is the same than the directory to package
TMP_DIR_PATH=/tmp	
TARFILE_NAME="$DIR_TO_PACKAGE_NAME".tar
TARFILE_PATH="$TMP_DIR_PATH"/"$TARFILE_NAME"
ZIPFILE_NAME="$DIR_TO_PACKAGE_NAME".zip
ZIPFILE_PATH="$TMP_DIR_PATH"/"$ZIPFILE_NAME"

# We move one directory above the directory to package, in order to run the tar command well
cd "$DIR_TO_PACKAGE_PATH"  || { echo 'ERROR: '"$DIR_TO_PACKAGE_PATH"' is invalid at the end of the script'; exit 1; }
cd ..	

# After running tar we move to the directory where the tar was created, in order to run the zip command well
tar -czvf "$TARFILE_PATH" "$DIR_TO_PACKAGE_NAME" && cd "$TMP_DIR_PATH" && zip -r "$ZIPFILE_NAME" --password "$2" "$TARFILE_NAME"
rm "$TARFILE_PATH"
mv "$ZIPFILE_PATH" "$CURRENT_DIR_PATH"

