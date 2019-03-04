#! /bin/bash

FILENAME=$1
EXTENSION_MAX_LENGTH=$2

if [[ "$FILENAME" == "."*"."* ]]    # Hidden files with extension
then
  HAS_EXTENSION=true; 
elif [[ "$FILENAME" == "."* ]]      # Hidden files without extension
then
  HAS_EXTENSION=false; 
elif [[ "$FILENAME" == *"."* ]]	    # Not hidden files with extension
then
  HAS_EXTENSION=true; 
else				    # Not hidden files without extension
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

echo $HAS_EXTENSION

