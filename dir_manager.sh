#!/usr/bin/env bash

OUTPUT_DIR=/tmp/dir_analysis
FILES_TO_ALTER_PATH=$OUTPUT_DIR/files_to_alter.txt
EXTENSION_MAX_LENGTH=5
INTERNAL_FILE_SEPARATOR='|'

print_help()
{
  echo "Usage: ./dir_manager.sh [OPTIONS] <DIR_TO_PROCESS>"
  echo -e "  -l\t\t\t\tConverts all the letters at filenames to lowercase"
  echo -e "  -s <term>\t\t\tReplaces with <term> all the spaces at filenames"  
  echo -e "  -r <type>\t\t\tRemoves all the files of type <type>"
  echo -e "  -m <type> <output_dir>\tMoves to <output_dir> all files of type <type> preserving the structure of subdirectories"
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

  FILENAME="${FILEPATH##*/}"

  if [[ "$FILENAME" == "."*"."* ]]	# Hidden files with extension
  then
    HAS_EXTENSION=true; 
  elif [[ "$FILENAME" == "."* ]]	# Hidden files without extension
  then
    HAS_EXTENSION=false; 
  elif [[ "$FILENAME" == *"."* ]]	# Not hidden files with extension
  then
    HAS_EXTENSION=true; 
  else					# Not hidden files without extension
    HAS_EXTENSION=false;
  fi

  if [ "$HAS_EXTENSION" = true ] ; then
    EXTENSION="${FILENAME##*.}"
    EXTENSION_LENGHT=${#EXTENSION}

    # Extensions longer than $EXTENSION_MAX_LENGTH are excluded
    if [ "$EXTENSION_LENGHT" -gt "$EXTENSION_MAX_LENGTH" ] ; then
      HAS_EXTENSION=false;
    fi

    # Extensions with characters other than letters and numbers are excluded
    if [[ "$EXTENSION" =~ [^a-zA-Z0-9] ]]; then
      HAS_EXTENSION=false;
    fi
  fi

  # Produce destination file copy path, if corresponds
  NEW_PATH=$FILEPATH
  
  if [ "$TO_LOWERCASE" = true ] ; then
    NEW_PATH=$(to_lower "$FILEPATH")
    EXTENSION=$(to_lower "$EXTENSION")
  fi

  if [ -n "$REPL_SPACES" ] ; then
    NEW_PATH=$(replace_spaces "$NEW_PATH" "$REPL_SPACES")
  fi

  # Collect files to remove
  if [ "$HAS_EXTENSION" = true ] && [ "$EXTENSION" == "$RM_EXTENSION" ] ; then
      echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$FILEPATH" >> $FILES_TO_ALTER_PATH
      return
  fi

  if [ "$EXTENSION" == "$MV_EXTENSION" ] && [ -n "$MV_OUTPUT" ] ; then
    NEW_PATH=$(get_external_path "$MV_OUTPUT" "$NEW_PATH")
  fi

  if [ "$NEW_PATH" != "$FILEPATH" ] ; then
    echo "$FILEPATH""$INTERNAL_FILE_SEPARATOR""$NEW_PATH" >> $FILES_TO_ALTER_PATH  
  fi
}

TO_LOWERCASE=false
REPL_SPACES=""
RM_EXTENSION=""
MV_EXTENSION=""
MV_OUTPUT=""

while [[ $# > 1 ]]
do
  KEY="$1"

  case $KEY in
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

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
cd "$DIR_TO_ANALYZE" || { echo 'Invalid directory'; exit 1; }

while read FILEPATH; do  
  process_single_file "\${FILEPATH}"
done < <(find -type f)

while IFS=$INTERNAL_FILE_SEPARATOR read -r SOURCE DEST; do
  if [ "$SOURCE" == "$DEST" ] ; then
    echo "Remove" "$SOURCE"
  else
    echo "Copy" "$SOURCE" "to" "$DEST"
  fi

done < $FILES_TO_ALTER_PATH
