#!/bin/bash

# Needed
# sudo apt-get update && sudo apt-get install imagemagick -y


# max height
WIDTH=1000

# max width
HEIGHT=1000


while read FILEPATH; do
  convert $FILEPATH -resize $WIDTHx$HEIGHT\> $FILEPATH
done < <( find . -iname '*.jpg' -o -iname '*.png')
