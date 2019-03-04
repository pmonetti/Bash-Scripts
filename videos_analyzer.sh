#! /bin/bash

print_help()
{
	echo "Usage: ./video_analizer.sh <DIR_TO_ANALYZE>"
}

ms_to_hh_mm_ss()
{
 TIME_IN_MS=$1
 TIME_IN_SECS=$TIME_IN_MS/1000
 ((HOURS="$TIME_IN_SECS"/3600))
 ((MINUTES=("$TIME_IN_SECS"%3600)/60))
 ((SECONDS="$TIME_IN_SECS"%60))
 printf "%02d:%02d:%02d\n" "$HOURS" "$MINUTES" "$SECONDS"
}

bytes_to_kbytes()
{
	SIZE_IN_B=$1
	((SIZE_IN_KB=($SIZE_IN_B+512)/1024))
	printf "%d\n" "$SIZE_IN_KB"	
}

format_in_thousands()
{
	RESULT=en_US printf "%'.f\n" $1	
	echo $RESULT
}

# EXECUTION STARTS HERE !


if [ "$#" -ne 1 ] ; then
    print_help
    exit 1
fi


DIR_TO_ANALYZE="$1"			# Quotes are needed to escape spaces

cd "$DIR_TO_ANALYZE" >> /dev/null 2>&1 || { echo "ERROR: ""$DIR_TO_ANALYZE"" is not a valid directory to operate on."; exit 1; }

while read FILEPATH; do
	
	DURATION=$(mediainfo --Output="General;%Duration%" "$FILEPATH")
	DURATION=$(ms_to_hh_mm_ss "$DURATION")
	FILESIZE=$(mediainfo --Output="General;%FileSize%" "$FILEPATH")
	FILESIZE=$(bytes_to_kbytes "$FILESIZE")
	FORMAT=$(mediainfo --Output="General;%Format%" "$FILEPATH")
	TOTAL_BPS=$(mediainfo --Output="General;%OverallBitRate%" "$FILEPATH")		
	TOTAL_KBPS=$(bytes_to_kbytes "$TOTAL_BPS")
	TOTAL_KBPS=$(format_in_thousands "$TOTAL_KBPS")
	
	
	VIDEO_FORMAT=$(mediainfo --Output="Video;%Format%" "$FILEPATH")	
	VIDEO_BPS=$(mediainfo --Output="Video;%BitRate%" "$FILEPATH")
	VIDEO_KBPS=$(bytes_to_kbytes "$VIDEO_BPS")
	VIDEO_KBPS=$(format_in_thousands "$VIDEO_KBPS")
	VIDEO_FRAMERATE=$(mediainfo --Output="Video;%FrameRate%" "$FILEPATH")	
	WIDTH=$(mediainfo --Output="Video;%Width%" "$FILEPATH")
	HEIGHT=$(mediainfo --Output="Video;%Height%" "$FILEPATH")
	
	AUDIO_FORMAT=$(mediainfo --Output="Audio;%Format%" "$FILEPATH")	
	AUDIO_BPS=$(mediainfo --Output="Audio;%BitRate%" "$FILEPATH")
	#AUDIO_KBPS=$(bytes_to_kbytes "$AUDIO_BPS")
	#AUDIO_KBPS=$(format_in_thousands "$AUDIO_KBPS")
	AUDIO_CHANNELS=$(mediainfo --Output="Audio;%Channel(s)%" "$FILEPATH")
	AUDIO_SAMPLING_RATE=$(mediainfo --Output="Audio;%SamplingRate%" "$FILEPATH")
	

	DIRPATH="${FILEPATH%/*}"
	DIRNAME=$(basename $DIRPATH)
	FILENAME=$(mediainfo --Output="General;%FileName%" "$FILEPATH")
	EXTENSION=$(mediainfo --Output="General;%FileExtension%" "$FILEPATH")

	echo "$EXTENSION""|""$DURATION""|""$FILESIZE""|""$FORMAT""|""$TOTAL_KBPS""|""$VIDEO_FORMAT""|""$VIDEO_KBPS""|""$VIDEO_FRAMERATE""|""$WIDTH""|""$HEIGHT""|""$AUDIO_FORMAT""|""$AUDIO_BPS""|""$AUDIO_CHANNELS""|""$AUDIO_SAMPLING_RATE""|""$DIRNAME""|""$FILENAME"
done < <(find "$(pwd)" -type f)

