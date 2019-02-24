#/bin/bash

print_help()
{
  echo "Usage: ./extract_backup.sh <DIR_WITH_PACKAGES> <PASS>"
  echo "   where <DIR_WITH_PACKAGES> can be absolute or relative to the current directory."  
}

process_single_file()
{
	eval ZIPPATH="$1"
	FILENAME="${ZIPPATH##*/}"
	BASENAME="${FILENAME%.zip}"
	OUTPUTDIR="$BASENAME"

	TARPATH="$BASENAME".tar
	DIR_SINGLE_PACKAGE_ANALYSIS="$DIR_ANALYSIS_PARENT"/"$BASENAME"_analysis/
	DIR_ANALYSIS_TXT="$DIR_SINGLE_PACKAGE_ANALYSIS"/"$BASENAME"_analysis.txt	
	TREE_TXT="$DIR_SINGLE_PACKAGE_ANALYSIS"/"$BASENAME"_tree.txt

	unzip -P "$2" "$ZIPPATH" -d . || exit 1
	mkdir -p "$OUTPUTDIR" || exit 1
	tar -xvzf "$TARPATH" || exit 1
	rm "$TARPATH" || exit 1 

	mkdir "$DIR_SINGLE_PACKAGE_ANALYSIS"
	~/Bash-Scripts/dir_analyzer.sh "$OUTPUTDIR" > "$DIR_ANALYSIS_TXT"
	tree -a "$OUTPUTDIR" > "$TREE_TXT"
	
	cp -r /tmp/dir_analysis/* "$DIR_SINGLE_PACKAGE_ANALYSIS"
}


if [ "$#" -ne 2 ] ; then
    print_help
    exit 1
fi

CURRENT_DIR_PATH=${PWD}
DIR_WITH_PACKAGES_PATH=$1
PASS=$2

# Check if DIR_WITH_PACKAGES_PATH is a valid directory and go back to the original directory
cd "$DIR_WITH_PACKAGES_PATH" || { echo 'ERROR: '"$DIR_WITH_PACKAGES_PATH"' is not a directory'; exit 1; }
cd "$CURRENT_DIR_PATH"

sudo apt-get install tree

DIR_ANALYSIS_PARENT="analysis"
MD5SUMS_FILE_PATH="$DIR_ANALYSIS_PARENT"/md5sum_all.txt

cd "$DIR_WITH_PACKAGES_PATH"

mkdir -p "$DIR_ANALYSIS_PARENT"
md5sum *.zip > "$MD5SUMS_FILE_PATH"

while read FILEPATH; do
  process_single_file "$FILEPATH" "$PASS"
done < <(find "$(pwd)" -type f | grep zip)
