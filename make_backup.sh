#/bin/bash
DIRPATH=$1
BACKUP_INFO_DIR=$3


cd $DIRPATH || { echo 'ERROR: Not a directory'; exit 1; }

# Remove trailing slash if exists
DIRPATH=$(echo ${@%/})

DIRNAME="${DIRPATH##*/}"
TARNAME="$DIRNAME".tar

mkdir -p "$BACKUP_INFO_DIR"

~/Bash-Scripts/dir_analyzer.sh "$DIRPATH" > "$BACKUP_INFO_DIR""$DIRNAME"_analysis.txt
cp -r /tmp/dir_analysis/ "$BACKUP_INFO_DIR""$DIRNAME"_analysis/

tree "$DIRPATH" > "$BACKUP_INFO_DIR""$DIRNAME"_tree.txt

tar -czvf "$TARNAME" * && zip -r "$DIRNAME".zip --password "$3" "$TARNAME"
rm "$TARNAME"
