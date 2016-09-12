#/bin/bash

bytes_to_readable_format()
{
  eval SIZE_IN_BYTES="$1"
  eval WITH_COLOR="$2"

  if [ "$WITH_COLOR" = false ] ; then
    echo $SIZE_IN_BYTES | awk '{ split( "B KB MB GB" , v ); s=1; while( $1>1024 ){ $1/=1024; s++ } print int($1) " " v[s] }'
    return
  fi

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