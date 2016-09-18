#!/usr/bin/env bash

print_help()
{
  echo "Usage: ./dir_manager.sh [OPTIONS] <DIR_TO_PROCESS>"
  echo -e "  -l\t\t\t\tConverts all the extensions to lowercase"
  echo -e "  -k\t\t\t\tKeep only english characters characters in paths"
  echo -e "  -s <term>\t\t\tReplaces with <term> all the spaces at filenames"
  echo -e "  -r <type>\t\t\tRemoves all the files of type <type>"
  echo -e "  -m <type> <output_dir>\tMoves to <output_dir> all files of type <type> preserving the structure of subdirectories"

  echo -e "Note: All <type> parameters are case insensitive"
}

to_lower()
{
  echo $1 | awk '{print tolower($0)}'
}

replace_spaces()
{
  STRING=$1
  INS_SRT=$2
  echo ${STRING// /$INS_SRT}
}

keep_english_chars()
{
  STRING=$1
  ENGLISH_STR=$(echo "$STRING" | iconv -f utf8 -t ascii//TRANSLIT)
  echo $ENGLISH_STR
}

get_external_path()
{
    OUT_DIR=$1
    RELATIVE_FILEPATH=$2

    if [[ "${OUT_DIR:0:1}" == / || "${OUT_DIR:0:2}" == ~[/a-z] ]] ; then
      ABS_OUT_DIR=$OUT_DIR
    else
      CURRENT_DIR=${PWD}
      ABS_OUT_DIR="$CURRENT_DIR"/"$OUT_DIR"
    fi

    echo $ABS_OUT_DIR"/"$RELATIVE_FILEPATH   
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
      echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$FILEPATH" >> $FILES_TO_ALTER_PATH
      echo $DIR
      return
  fi

  # Produce destination file copy path, if corresponds
  NEW_PATH=$FILEPATH

  if [ "$HAS_EXTENSION" = true ] && [ "$TO_LOWERCASE" = true ] ; then
    BASENAME="${FILENAME%.*}"
    NEW_PATH=$DIR"/"$BASENAME"."$EXTENSION
  fi

  if [ "$KEEP_ENGLISH_CHARS" = true ] ; then
    NEW_PATH=$(keep_english_chars "$NEW_PATH")
  fi

  if [ -n "$REPL_SPACES" ] ; then
    NEW_PATH=$(replace_spaces "$NEW_PATH" "$REPL_SPACES")
  fi

  if [ "$EXTENSION" == "$MV_EXTENSION" ] && [ -n "$MV_OUTPUT" ] ; then
    NEW_PATH=$(get_external_path "$MV_OUTPUT" "$NEW_PATH")
  fi

  # For each file that will be moved or renamed write a line <FILEPATH>|<NEW_PATH> in the file that lists files to alter
  if [ "$NEW_PATH" != "$FILEPATH" ] ; then
    echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$NEW_PATH" >> $FILES_TO_ALTER_PATH  
    echo $DIR
  fi
}

recursive_rm_dir()
{
  eval DIR_PATH="$1"			# (1)

  if [ "$DIR_PATH" == "." ] ; then
    return
  fi

  rmdir "$DIR_PATH" > /dev/null 2>&1 && echo "$DIR_PATH" "directory became empty so it was removed"
  DIR_ALTERED="${DIR_ALTERED%/*}"
  recursive_rm_dir "\${DIR_ALTERED}"
}

# EXECUTION STARTS HERE !

TO_LOWERCASE=false
KEEP_ENGLISH_CHARS=false
REPL_SPACES=""
RM_EXTENSION=""
MV_EXTENSION=""
MV_OUTPUT=""

while [[ $# > 1 ]]
do
  KEY="$1"

  case $KEY in
      -k|--keepenglish)
      KEEP_ENGLISH_CHARS=true
      ;;

      -l|--lowercase)
      TO_LOWERCASE=true
      ;;

      -s|--spaces)
      REPL_SPACES="$2"
      shift 				# past argument
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

      *)
					# unknown option
      ;;
  esac

  shift # past argument or value
done

if [ "$#" -ne 1 ]; then
    print_help
    exit
fi

DIR_TO_ANALYZE="$1"			# Quotes are needed to escape spaces
OUTPUT_DIR=/tmp/dir_analysis
FILES_TO_ALTER_PATH=$OUTPUT_DIR/files_to_alter.txt
DIRS_TO_ALTER_PATH=$OUTPUT_DIR/dirs_to_alter.txt
EXTENSION_MAX_LENGTH=5
INTERNAL_FILE_SEPARATOR='|'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
cd "$DIR_TO_ANALYZE" || { echo 'Invalid directory'; exit 1; }

RM_EXTENSION=$(to_lower "$RM_EXTENSION")
MV_EXTENSION=$(to_lower "$MV_EXTENSION")

while read FILEPATH; do  
  process_single_file "\${FILEPATH}"
done < <(find -type f)  > >(awk '!a[$0]++' | sort > $DIRS_TO_ALTER_PATH)

sleep 1

while IFS=$INTERNAL_FILE_SEPARATOR read -r SOURCE DEST; do
  if [ "$SOURCE" == "$DEST" ] ; then
    echo "rm" "$SOURCE"
  else
    echo "cp" "$SOURCE" "$DEST"
  fi

done < $FILES_TO_ALTER_PATH

while read DIR_ALTERED; do
    recursive_rm_dir "\${DIR_ALTERED}"
done < $DIRS_TO_ALTER_PATH



# (1) This complex line is needed to avoid having problems with filenames that contains spaces