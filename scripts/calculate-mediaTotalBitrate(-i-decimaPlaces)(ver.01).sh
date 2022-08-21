#!/bin/bash

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


# Import external script
# winx2unix: script converts a dos-style-ended string
#to a unix-style-ended strings
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"

conv2DecKilo="${scriptDirectoryPath}/conv2DecKilo(-number-decimalPlaces).sh"

getMediaDurationSecsDP="${scriptDirectoryPath}/ffprobe-mediaLength_seconds(-i-decimaPlaces).sh"

getMediaSize="${scriptDirectoryPath}/ffprobe-mediaSize_bytes(-i).sh"


# End of list of shells

media="$1"
decimaPlaces="$2"

mediaSize="$(bash "${getMediaSize}" "${media}")"

mediaSizeKB="$(bash "${conv2DecKilo}" "${mediaSize}" 10)"

mediaDuration="$(bash "${getMediaDurationSecsDP}" "${media}" 10)"

mediaTotalBitrate=`printf "%.${decimaPlaces}f\n" "$( echo "scale=25;
${mediaSize} * 8 / ${mediaDuration}" | bc -l)"`

echo "${mediaTotalBitrate}"

# test