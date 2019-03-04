#! /bin/bash

# The utils.sh script is required to use the following functions:
# print_in_green
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

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

	echo "$BASENAME"": extracting zip file.."
	unzip -P "$2" "$ZIPPATH" -d .  > /dev/null || exit 1
	mkdir -p "$OUTPUTDIR" || exit 1
	echo "$BASENAME"": extracting tar file.."
	tar -xvzf "$TARPATH"  > /dev/null || exit 1
	rm "$TARPATH" || exit 1 

	echo "$BASENAME"": getting and saving data about extracted files.."
	mkdir "$DIR_SINGLE_PACKAGE_ANALYSIS" || exit 1
	~/Bash-Scripts/dir_analyzer.sh "$OUTPUTDIR" > "$DIR_ANALYSIS_TXT" || exit 1
	tree -a "$OUTPUTDIR" > "$TREE_TXT" || exit 1
	
	cp -r /tmp/dir_analysis/* "$DIR_SINGLE_PACKAGE_ANALYSIS" || exit 1
}


if [ "$#" -ne 2 ] ; then
    print_help
    exit 1
fi

CURRENT_DIR_PATH=${PWD}
DIR_WITH_PACKAGES_PATH=$1
PASS=$2

# Check if DIR_WITH_PACKAGES_PATH is a valid directory and go back to the original directory
cd "$DIR_WITH_PACKAGES_PATH" || exit 1
cd "$CURRENT_DIR_PATH"

sudo apt-get install tree > /dev/null ||  exit 1

DIR_ANALYSIS_PARENT="analysis"
MD5SUMS_FILE_PATH="$DIR_ANALYSIS_PARENT"/md5sum_all.txt

cd "$DIR_WITH_PACKAGES_PATH"

rm -rf "$DIR_ANALYSIS_PARENT" ||  exit 1
mkdir -p "$DIR_ANALYSIS_PARENT" ||  exit 1

echo "Calculating md5sums for all packages.."
md5sum *.zip > "$MD5SUMS_FILE_PATH" ||  exit 1

while read FILEPATH; do
	print_in_green "--- $FILEPATH ---"
	process_single_file "$FILEPATH" "$PASS"
done < <(find "$(pwd)" -type f | grep zip)
