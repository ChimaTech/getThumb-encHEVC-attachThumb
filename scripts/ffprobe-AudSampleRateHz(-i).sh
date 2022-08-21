#!/bin/bash

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


# Import external script
# winx2unix: script converts a dos-style-ended string
#to a unix-style-ended strings
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"


#Assign the target media to a variable
media=$1

# Assign a text file to temporarily hold $mediaAudioSampleRateHz
#+ so that we can take the first line from, just in case ...
#+ $mediaAudioSampleRateHz is a multiple line of characters
tempTxtFile="temp.txt"

#ffprobe to get the media's video stream bitrate
mediaAudioSampleRateHz=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "${media}")

# Print mediaAudioSampleRateHz inside tempTxtFile
echo "${mediaAudioSampleRateHz}" > "${tempTxtFile}"

# Take the first line from tempTxtFile
firstLine="$(head -n 1 "${tempTxtFile}" )"

# Delete the tempTxtFile
rm -rf "${tempTxtFile}"

# Assign the $firstLine to $mediaAudioSampleRateHz
mediaAudioSampleRateHz="${firstLine}"

#convert value to unix-style-ended string
mediaAudioSampleRateHz=$(sh "${winx2unix}" "${mediaAudioSampleRateHz}")

#echo the final result
echo "${mediaAudioSampleRateHz}"

#EXAMPLE: to get the video-stream bit_rate of $inputMedia, call:
# sh $thisScript v $inputMedia