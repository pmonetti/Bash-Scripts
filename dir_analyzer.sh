#/bin/bash

DIR_TO_ANALYZE="$1"			# Quotes are needed to escape spaces

OUTPUT_DIR=/tmp/dir_analysis
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

declare -A SIZES
declare -A COUNTERS

print_help()
{
  echo "Usage: ./dir_analizer.sh <DIR_TO_ANALYZE>"
}

process_single_file(){
  eval FILEPATH="$1"			# (1)
  echo $FILEPATH >> $FIND_RES_PATH

  FILE_SIZE=$(get_size "\${FILEPATH}")	# (1)

  let TOTAL_FILES=$TOTAL_FILES+1
  let TOTAL_SIZE=$TOTAL_SIZE+$FILE_SIZE  

  FILENAME="${FILEPATH##*/}"
  HAS_EXTENSION=$($SCRIPT_DIR/has_extension.sh "$FILENAME" $EXTENSION_MAX_LENGTH)

  if [ "$HAS_EXTENSION" = "true" ] ; then
    EXTENSION="${FILENAME##*.}"
    echo $EXTENSION
    echo $FILEPATH >> $OUTPUT_DIR/my_$EXTENSION\_files.txt       

    if test "${SIZES[$EXTENSION]+isset}";
    then
      let SIZES[$EXTENSION]=SIZES[$EXTENSION]+$FILE_SIZE
    else 
      let SIZES[$EXTENSION]=$FILE_SIZE
    fi;

    if test "${COUNTERS[$EXTENSION]+isset}";
    then
      let COUNTERS[$EXTENSION]=COUNTERS[$EXTENSION]+1
    else
      let COUNTERS[$EXTENSION]=1
    fi;
  else
      echo $FILEPATH >> $WITHOUT_EXTENSIONS_PATH  
      let WITHOUT_EXTENSION_COUNTER=$WITHOUT_EXTENSION_COUNTER+1
      let WITHOUT_EXTENSION_ACCUM_SIZE=$WITHOUT_EXTENSION_ACCUM_SIZE+$FILE_SIZE
  fi
}

get_size()
{
  eval FILEPATH="$1"			# (1)
  echo $(stat --printf="%s" "$FILEPATH")
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
cd "$DIR_TO_ANALYZE"




# Extract all the files extensions of the files contained below the current directory and write them to $EXTENSIONS_PATH, ordered and without duplicates
while read FILEPATH; do
  process_single_file "\${FILEPATH}"
done < <(find "$(pwd)" -type f) > >(awk '!a[$0]++' | sort > $EXTENSIONS_PATH)

sleep 1

init_table
print_table_header

while read EXTENSION; do
  FILE_CLASS_SIZE="${SIZES[$EXTENSION]}"
  HUMAN_READABLE_SIZE=$(bytes_to_readable_format "\${FILE_CLASS_SIZE}")
  COUNT="${COUNTERS[$EXTENSION]}"
  printf "$ROW_FORMAT" $EXTENSION $COUNT "$HUMAN_READABLE_SIZE"
done < $EXTENSIONS_PATH

print_weak_table_divider

HUMAN_READABLE_SIZE=$(bytes_to_readable_format "\${WITHOUT_EXTENSION_ACCUM_SIZE}")
printf "$ROW_FORMAT" "Other" $WITHOUT_EXTENSION_COUNTER "$HUMAN_READABLE_SIZE"

print_strong_table_divider

HUMAN_READABLE_SIZE=$(bytes_to_readable_format $TOTAL_SIZE)
printf "$ROW_FORMAT" "Total" $TOTAL_FILES "$HUMAN_READABLE_SIZE"
echo

cd - > /dev/null


# (1) This complex line is needed to avoid having problems with filenames that contains spaces