#! /bin/bash

bytes_to_readable_format()
{
  eval SIZE_IN_BYTES="$1"
  eval WITH_COLOR="$2"

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

  function without_color(s) {
      print s;
  }

  {
    split("B KB MB GB", v); 
    i=1; 

    while( $1>1024 ){
      $1/=1024; 
      i++;
    };

    CONVFMT = "%.1f";
    text=$1 " " v[i];

    if($2 == "false")
      without_color(text);
    else if(v[i] == "GB")
      red(text);
    else if (v[i] == "MB")
      green(text);
    else
      white(text);
  }'

  echo "$SIZE_IN_BYTES" "$WITH_COLOR" | awk "$AWK_SCRIPT"
}

get_linux_version_id()
{
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		echo $VERSION_ID
	else
		echo "Linux Version Id Not Found"
	fi	
}

get_size()
{
  eval FILEPATH="$1"		# (1)
  echo $(stat --printf="%s" "$FILEPATH")
}

invalid_dir_path()
{
    INPUT_PATH="$1"
    if [ -d "$INPUT_PATH" ] ; then
        return 1    # false = 1
    else
        return 0    # true = 0
    fi
}

is_relative_path()
{
    INPUT_PATH="$1"
    if [[ "$INPUT_PATH" = /* ]]; then
        return 1    # false = 1
    else
        return 0    # true = 0
    fi
}

keep_english_chars()
{
  STRING="$1"
  ENGLISH_STR=$(echo "$STRING" | iconv -f utf8 -t ascii//TRANSLIT)
  echo "$ENGLISH_STR"
}

make_dir_path_absolute()
{
    INPUT_PATH="$1"    
	echo "$( cd "$INPUT_PATH" && pwd )"
}

print_in_green()
{
	CMD="$1"
	GREEN='\033[0;32m'
	NO_COLOR='\033[0m'	
	printf "${GREEN}${CMD}${NO_COLOR}\n"	
}

print_and_exec()
{
	CMD="$1"
	print_in_green "$CMD"
	eval "$CMD"
	echo
}

replace_strings()
{
  STRING="$1"
  OLD_STR="$2"
  NEW_STR="$3"
  echo ${STRING//$OLD_STR/$NEW_STR}
}

to_lower()
{
  echo "$1" | awk '{print tolower($0)}'
}
