#!/bin/bash

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


# Import external script
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"


#Assign the target media to a variable
mediaValue=$1
decimalPlaces=$2

mediaValueKilo=`printf "%.${decimalPlaces}f\n" "$(echo "scale=10;
${mediaValue} / 1000" | bc -l)"`

mediaValueKilo="$(bash "${winx2unix}" "${mediaValueKilo}")"

echo "${mediaValueKilo}"