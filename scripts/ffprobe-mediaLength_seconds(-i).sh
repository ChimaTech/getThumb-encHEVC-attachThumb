#!/bin/bash

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


# Import external script
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"


#Assign the target media to a variable
media=$1

#ffprobe to get the media duration in seconds
medialengthSecs="$(ffprobe -v error \
-show_entries format=duration \
-of default=noprint_wrappers=1:nokey=1 "${media}")"

#convert value to unix-style-ended string
medialengthSecs=$(sh "${winx2unix}" "${medialengthSecs}")

#echo the final result
echo "${medialengthSecs}"