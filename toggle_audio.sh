#!/bin/bash

CURRENT_PROFILE=$(pacmd list-cards | grep "active profile" | cut -d ' ' -f 3-)

if [ "$CURRENT_PROFILE" = "<output:hdmi-stereo+input:analog-stereo>" ] ; then
        pacmd set-card-profile 0 "output:analog-stereo+input:analog-stereo"
        echo "Analog Stereo selected"
else
        pacmd set-card-profile 0 "output:hdmi-stereo+input:analog-stereo"
        echo "HDMI Stereo selected"        
fi
