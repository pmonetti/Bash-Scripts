#/bin/bash

DIR_TO_ANALYZE=$1
OUTPUT_DIR=/tmp/dir_analysis/
FIND_RES_PATH=$OUTPUT_DIR/find_results.txt
EXTENSIONS_PATH=$OUTPUT_DIR/extensions.txt
EXTRA_ACCUMS_PATH=$OUTPUT_DIR/extra_accumulators.txt
WITHOUT_EXTENSIONS_PATH=$OUTPUT_DIR/my_without_extensions_files.txt
EXTENSION_MAX_LENGTH=5

WITHOUT_EXTENSION_COUNTER=0
WITHOUT_EXTENSION_ACCUM_SIZE=0
TOTAL_FILES=0
TOTAL_SIZE=0

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_help()
{
  echo "Usage: ./incremental_dir_analizer.sh <DIR_TO_ANALYZE>"
}

process_file()
{
  eval FILEPATH="$1"		# (1)
  FILENAME="${FILEPATH##*/}"
  HAS_EXTENSION=$($SCRIPT_DIR/has_extension.sh "$FILENAME" $EXTENSION_MAX_LENGTH)

  if [ "$HAS_EXTENSION" = "true" ] ; then
    EXTENSION="${FILENAME##*.}"
    echo $EXTENSION
    let WITH_EXTENSION_COUNTER=$WITH_EXTENSION_COUNTER+1
  else
    echo $FILEPATH >> $WITHOUT_EXTENSIONS_PATH
    let WITHOUT_EXTENSION_COUNTER=$WITHOUT_EXTENSION_COUNTER+1
    FILE_SIZE=$(get_size "\${FILEPATH}")	# (1)
    let WITHOUT_EXTENSION_ACCUM_SIZE=$WITHOUT_EXTENSION_ACCUM_SIZE+$FILE_SIZE
  fi
}

get_size()
{
  eval FILEPATH="$1"		# (1)
  echo $(stat --printf="%s" "$FILEPATH")
}

process_extensions()
{
  read EXTENSION;
  ALL_EXTENSIONS=$EXTENSION
  EXTENSION_COUNTER=0 
  MAX_EXT=""

  while read EXTENSION; do
    ALL_EXTENSIONS=$ALL_EXTENSIONS", "$EXTENSION 

    let EXTENSION_COUNTER=EXTENSION_COUNTER+1

    LINE_LEN=${#EXTENSION}
    if [[ "$LINE_LEN" -ge "$EXTENSION_MAX_LENGTH" ]];then
      EXTENSION_MAX_LENGTH=$LINE_LEN
      MAX_EXT=$EXTENSION
    fi

  done
  echo $EXTENSION_COUNTER" extensions found: "$ALL_EXTENSIONS"."
}

bytes_to_readable_format()
{
  eval SIZE_IN_BYTES="$1"
  #echo $SIZE_IN_BYTES | awk '{ split( "B KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) " " v[s] }'

  AWK_SCRIPT='
  function red(s) {
      printf "\033[1;31m" s "\033[0m ";
  }
  function green(s) {
      printf "\033[0;32m" s "\033[0m ";
  }
  function white(s) {
      printf "\033[0;37m" s "\033[0m ";
  }
  {
    split( "B KB MB GB" , v ); 
    i=1; 
    while( $1>1024 ){
      $1/=1024; 
      i++;
    };
    CONVFMT = "%.2f";
    text=$1 " " v[i];
    if(v[i] == "GB")
      red(text);
    else if (v[i] == "MB")
      green(text);
    else
      white(text);
  }'

  echo $SIZE_IN_BYTES | awk "$AWK_SCRIPT"

}

init_table(){
  STRONG_TABLE_DIVIDER===============================
  STRONG_TABLE_DIVIDER=$STRONG_TABLE_DIVIDER$STRONG_TABLE_DIVIDER

  WEAK_TABLE_DIVIDER=------------------------------
  WEAK_TABLE_DIVIDER=$WEAK_TABLE_DIVIDER$WEAK_TABLE_DIVIDER

  HEADER_FORMAT="\n %"$EXTENSION_MAX_LENGTH"s %7s %11s\n"
  ROW_FORMAT=" %"$EXTENSION_MAX_LENGTH"s %7s %23s\n"

  let TABLE_WIDTH=$EXTENSION_MAX_LENGTH+21
}

print_strong_table_divider(){
  printf " %$TABLE_WIDTH.${TABLE_WIDTH}s\n" "$STRONG_TABLE_DIVIDER"
}

print_weak_table_divider(){
  printf " %$TABLE_WIDTH.${TABLE_WIDTH}s\n" "$WEAK_TABLE_DIVIDER"
}

print_table_header(){
  printf "$HEADER_FORMAT" "Type" "Files" "Size"
  print_strong_table_divider
}






# EXECUTION STARTS HERE !

if [ "$#" -ne 1 ]; then
    print_help
    exit
fi

# Prepare and clean the output directory; then change the current directory to the one that will be analyzed
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
cd $DIR_TO_ANALYZE
echo

# Extract the paths of all regular files (not dirs) below the dir to analyze and write them into $FIND_RES_PATH
find $(pwd) -type f | tee >(echo "$(wc -l) files found.") > $FIND_RES_PATH

# Extract all the file extensions from the paths at $FIND_RES_PATH and write them to $EXTENSIONS_PATH, ordered and without duplicates
while read FILEPATH; do
  process_file "\${FILEPATH}"	# (1)
done < <(cat $FIND_RES_PATH) > >(awk '!a[$0]++' | sort > $EXTENSIONS_PATH)

sleep 1

# Print list of found extensions and find maximum extension length, needed to format the output table
process_extensions < $EXTENSIONS_PATH

init_table
print_table_header

while read EXTENSION; do  
  rm -f $OUTPUT_DIR/my_$EXTENSION\_files.txt

  FILE_CLASS_SIZE=0
  FILE_CLASS_COUNTER=0

  while read FILEPATH; do
    if [[ "$FILEPATH" == *".""$EXTENSION" ]]
    then
      let FILE_CLASS_COUNTER=$FILE_CLASS_COUNTER+1
      echo $FILEPATH >> $OUTPUT_DIR/my_$EXTENSION\_files.txt
      FILE_SIZE=$(get_size "\${FILEPATH}")	# (1)
      let FILE_CLASS_SIZE=$FILE_CLASS_SIZE+$((FILE_SIZE))
    fi
  done < $FIND_RES_PATH

  HUMAN_READABLE_SIZE=$(bytes_to_readable_format "\${FILE_CLASS_SIZE}")
  printf "$ROW_FORMAT" $EXTENSION $FILE_CLASS_COUNTER "$HUMAN_READABLE_SIZE"

  let TOTAL_FILES=$TOTAL_FILES+$FILE_CLASS_COUNTER
  let TOTAL_SIZE=$TOTAL_SIZE+$((FILE_CLASS_SIZE))

done < $EXTENSIONS_PATH

print_weak_table_divider

HUMAN_READABLE_SIZE=$(bytes_to_readable_format $WITHOUT_EXTENSION_ACCUM_SIZE)
printf "$ROW_FORMAT" "Other" $WITHOUT_EXTENSION_COUNTER "$HUMAN_READABLE_SIZE"

print_strong_table_divider

let TOTAL_FILES=$TOTAL_FILES+$WITHOUT_EXTENSION_COUNTER
let TOTAL_SIZE=$TOTAL_SIZE+$((WITHOUT_EXTENSION_ACCUM_SIZE))

HUMAN_READABLE_SIZE=$(bytes_to_readable_format $TOTAL_SIZE)
printf "$ROW_FORMAT" "Total" $TOTAL_FILES "$HUMAN_READABLE_SIZE"
echo

cd - > /dev/null


# (1) This complex line is needed to avoid having problems with filenames that contains spaces