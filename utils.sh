#/bin/bash

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

print_and_exec()
{
	CMD="$1"
	RED='\033[0;31m'
	NO_COLOR='\033[0m'	
	printf "${RED}${CMD}${NO_COLOR}\n"
	eval $CMD
	echo
}
