#! /bin/bash

# The utils.sh script is required to use the following functions:
# invalid_dir_path, is_relative_path, keep_english_chars,
# replace_strings, to_lower
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/utils.sh

print_help()
{
  echo "Usage: ./dir_manager.sh [OPTIONS] <DIR_TO_PROCESS>"
  echo -e "  -l, --lowercase\t\t\t\tConverts all the extensions (not dir nor file names) to lowercase in files below DIR_TO_PROCESS"
  echo -e "  -k, --keepenglish\t\t\t\tKeep only english characters characters in paths below DIR_TO_PROCESS"
  echo -e "  -p, --replace <old> <new>\t\t\tReplaces occurrences of <old> with <new> in paths below DIR_TO_PROCESS"
  echo -e "  -r, --remextension <type>\t\t\tRemoves all the files of type <type> below DIR_TO_PROCESS"
  echo -e "  -m, --mvoutput <type> <output_dir>\t\tMoves to <output_dir> all files of type <type>, below DIR_TO_PROCESS, preserving the structure of subdirectories"
  echo -e "  -v, --verbose\t\t\t\t\tVerbose output"

  echo -e "Note: All <type> parameters are case insensitive"
}

process_single_file()
{
  eval FILEPATH="$1"			# (1)

  DIR=$(dirname "${FILEPATH}")
  FILENAME="${FILEPATH##*/}"

  HAS_EXTENSION=$($SCRIPT_DIR/has_extension.sh "$FILENAME" $EXTENSION_MAX_LENGTH)
  EXTENSION="${FILENAME##*.}"
  EXTENSION=$(to_lower "$EXTENSION")

  # For each file that will be removed write a line <FILEPATH>|<FILEPATH> in the file that lists files to alter
  if [ "$HAS_EXTENSION" = true ] && [ "$EXTENSION" == "$RM_EXTENSION" ] ; then
      echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$FILEPATH" >> "$FILES_TO_ALTER_PATH"
      echo "$DIR"
      return
  fi

  # Produce destination file copy path, if corresponds
  NEW_PATH="$FILEPATH"

  if [ "$HAS_EXTENSION" = true ] && [ "$TO_LOWERCASE" = true ] ; then
    BASENAME="${FILENAME%.*}"
    NEW_PATH="$DIR""/""$BASENAME"".""$EXTENSION"
  fi

  if [ "$KEEP_ENGLISH_CHARS" = true ] ; then
    NEW_PATH=$(keep_english_chars "$NEW_PATH")
  fi

  if [ -n "$REPL_OLD" ] ; then
    NEW_PATH=$(replace_strings "$NEW_PATH" "$REPL_OLD" "$REPL_NEW")
  fi

  if [ "$EXTENSION" == "$MV_EXTENSION" ] && [ -n "$MV_OUTPUT" ] ; then
    NEW_PATH="$MV_OUTPUT"/"$NEW_PATH"
  fi

  # For each file that will be moved or renamed write a line <FILEPATH>|<NEW_PATH> in the file that lists files to alter
  if [ "$NEW_PATH" != "$FILEPATH" ] ; then
    echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$NEW_PATH" >> "$FILES_TO_ALTER_PATH"
    echo "$DIR"
  fi
}

recursive_rm_dir()
{
  eval DIR_PATH="$1"			# (1)

  if [ "$DIR_PATH" == "." ] ; then
    return
  fi

  rmdir "$DIR_PATH" > /dev/null 2>&1 && echo "$DIR_PATH" >> "$DIRS_TO_REMOVE_PATH"
  DIR_ALTERED="${DIR_ALTERED%/*}"
  recursive_rm_dir "\${DIR_ALTERED}"
}

# EXECUTION STARTS HERE !

TO_LOWERCASE=false
KEEP_ENGLISH_CHARS=false
REPL_OLD=""
REPL_NEW=""
RM_EXTENSION=""
MV_EXTENSION=""
MV_OUTPUT=""
VERBOSE=false

while [[ $# > 1 ]]
do
  KEY="$1"

  case $KEY in
      -h|--help)
      ;;

      -k|--keepenglish)
      KEEP_ENGLISH_CHARS=true
      ;;

      -l|--lowercase)
      TO_LOWERCASE=true
      ;;

      -p|--replace)
      REPL_OLD="$2"
      REPL_NEW="$3"
      shift 				# past argument 1
      shift 				# past argument 2
      ;;

      -r|--remextension)
      RM_EXTENSION="$2"
      shift 				# past argument
      ;;

      -m|--mvoutput)
      MV_EXTENSION="$2"
      MV_OUTPUT="$3"
      shift 				# past argument 1
      shift 				# past argument 2
      ;;

      -v|--verbose)
      VERBOSE=true
      ;;

      *)                                # unknown option
      echo "Unknown Option: "$KEY
      print_help
      exit 1
      ;;
  esac

  shift                                 # past argument or value
done

if [ "$#" -ne 1 ]; then
    print_help
    exit 1
fi

if [ -n "$MV_OUTPUT" ] && is_relative_path "$MV_OUTPUT" ; then
    CURRENT_DIR=${PWD}
    MV_OUTPUT="$CURRENT_DIR"/"$MV_OUTPUT"
fi

DIR_TO_ADMIN="$1"			# Quotes are needed to escape spaces
OUTPUT_DIR=/tmp/dir_manager
FILES_TO_ALTER_PATH="$OUTPUT_DIR""/files_to_alter.txt"
DIRS_TO_ALTER_PATH="$OUTPUT_DIR""/dirs_to_alter.txt"
DIRS_TO_REMOVE_PATH="$OUTPUT_DIR""/dirs_to_remove.txt"
EXTENSION_MAX_LENGTH=5
INTERNAL_FILE_SEPARATOR="|"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cd "$DIR_TO_ADMIN" >> /dev/null 2>&1 || { echo "ERROR: ""$DIR_TO_ADMIN"" is not a valid directory to operate on."; exit 1; }

RM_EXTENSION=$(to_lower "$RM_EXTENSION")
MV_EXTENSION=$(to_lower "$MV_EXTENSION")

# Create accumulative files to avoid future errors in case of no containing records
touch "$FILES_TO_ALTER_PATH"
touch "$DIRS_TO_ALTER_PATH"
touch "$DIRS_TO_REMOVE_PATH"

while read FILEPATH; do
  process_single_file "\${FILEPATH}"
done < <(find -type f)  > >(awk '!a[$0]++' | sort > "$DIRS_TO_ALTER_PATH")

sleep 1

RM_COUNT=0
MV_COUNT=0
while IFS="$INTERNAL_FILE_SEPARATOR" read -r SOURCE DEST; do
  if [ "$SOURCE" == "$DEST" ] ; then
    rm "$SOURCE"
    let RM_COUNT="$RM_COUNT"+1
    if [ "$VERBOSE" = true ] ; then echo "Remove: ""$SOURCE"; fi
  else
    DESTDIR=$(dirname "${DEST}")
    mkdir -p "$DESTDIR"
    mv "$SOURCE" "$DEST"
    let MV_COUNT="$MV_COUNT"+1
    if [ "$VERBOSE" = true ] ; then echo "Move: ""$SOURCE"" -> ""$DEST"; fi
  fi
done < "$FILES_TO_ALTER_PATH"

while read DIR_ALTERED; do
    recursive_rm_dir "\${DIR_ALTERED}"
done < "$DIRS_TO_ALTER_PATH"

RMDIR_COUNT=0
while read REMOVED_DIR_PATH; do
    let RMDIR_COUNT="$RMDIR_COUNT"+1
    if [ "$VERBOSE" = true ] ; then echo "Remove Empty Dir: ""$REMOVED_DIR_PATH"; fi
done < "$DIRS_TO_REMOVE_PATH"

echo "$RM_COUNT"" files removed"
echo "$MV_COUNT"" files moved"
echo "$RMDIR_COUNT"" directories removed after becoming empty"

# (1) This complex line is needed to avoid having problems with filenames that contains spaces
