#/bin/bash

print_help()
{
  echo "Usage: ./extract_backup.sh <DIR_WITH_PACKAGES> <PASS>"
}

process_single_file()
{
	eval ZIPPATH="$1"
	FILENAME="${ZIPPATH##*/}"
	BASENAME="${FILENAME%.zip}"
	OUTPUTDIR="$BASENAME"
	TARPATH="$BASENAME".tar
	DIR_ANALYSIS_TXT="$ANALYSIS_DIR"/"$BASENAME"_analysis.txt
	DIR_ANALYSIS_OUTDIR="$ANALYSIS_DIR"/"$BASENAME"_analysis/
	TREE_TXT="$ANALYSIS_DIR"/"$BASENAME"_tree.txt	

	unzip -P "$2" "$ZIPPATH" -d . || exit 1
	mkdir -p "$OUTPUTDIR" || exit 1
	tar -xvzf "$TARPATH" || exit 1
	rm "$TARPATH" || exit 1 
	
	~/Bash-Scripts/dir_analyzer.sh "$OUTPUTDIR" > "$DIR_ANALYSIS_TXT"
	tree -a "$OUTPUTDIR" > "$TREE_TXT"
	
	cp -r /tmp/dir_analysis/ "$DIR_ANALYSIS_OUTDIR"
	
	mv "$DIR_ANALYSIS_TXT" "$DIR_ANALYSIS_OUTDIR"
	mv "$TREE_TXT" "$DIR_ANALYSIS_OUTDIR"
}


if [ "$#" -ne 2 ] ; then
    print_help
    exit 1
fi

CURRENT_DIR_PATH=${PWD}
DIR_WITH_PACKAGES_PATH=$1
PASS=$2

# Check if DIR_WITH_PACKAGES_PATH is a valid directory
cd "$DIR_WITH_PACKAGES_PATH" || { echo 'ERROR: '"$DIR_WITH_PACKAGES_PATH"' is not a directory'; exit 1; }
cd "$CURRENT_DIR_PATH"


ANALYSIS_DIR="analysis"
MD5SUMS_FILE_PATH="$ANALYSIS_DIR"/md5sum_all.txt

cd "$DIR_WITH_PACKAGES_PATH"

mkdir -p "$ANALYSIS_DIR"
md5sum *.zip > "$MD5SUMS_FILE_PATH"

while read FILEPATH; do
  process_single_file "$FILEPATH" "$PASS"
done < <(find "$(pwd)" -type f | grep zip)
