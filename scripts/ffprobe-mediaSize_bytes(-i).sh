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

#ffprobe to get the media total size
mediaSize="$(ffprobe -v error \
-show_entries format=size \
-of default=noprint_wrappers=1:nokey=1 "${media}")"

#convert value to unix-style-ended string
mediaSize=$(sh "${winx2unix}" "${mediaSize}")

#echo the final result
echo "${mediaSize}"
    