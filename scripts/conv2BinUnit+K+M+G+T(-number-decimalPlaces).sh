#!/bin/bash

# DESCRIPTION:
# INPUT: numbers & no.of decimalPlaces
# OUTPUT: (string) {via binary division}
# Format == "converted number""the unit letter"

# HOW TO RUN example:
    # bash "this_Script.sh" 1234567890 4

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"

# Import external script
winx2unix="/${scriptDirectoryPath}/winx2unix(string).sh"


numberz="$1"

decimalPlaces="$2"


minimumBinKilo=`printf "%.3f\n" "$( echo "scale=6;1024^1" | bc -l)"`

minimumBinMega=`printf "%.3f\n" "$( echo "scale=6;1024^2" | bc -l)"`

minimumBinGiga=`printf "%.3f\n" "$( echo "scale=6;1024^3" | bc -l)"`

minimumBinTera=`printf "%.3f\n" "$( echo "scale=6;1024^4" | bc -l)"`

if [ "$( echo "${numberz} >= ${minimumBinKilo}" | bc -l)" -eq 1 ] &&  [ "$( echo "${numberz} < ${minimumBinMega}" | bc -l)" -eq 1 ]
    then 
        selectUnitLetter="K"
        selectDenominator="${minimumBinKilo}"
    
    elif [ "$( echo "${numberz} >= ${minimumBinMega}" | bc -l)" -eq 1 ] && [ "$( echo "${numberz} < ${minimumBinGiga}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="M"
        selectDenominator="${minimumBinMega}"
    
    elif [ "$( echo "${numberz} >= ${minimumBinGiga}" | bc -l)" -eq 1 ] && [ "$( echo "${numberz} < ${minimumBinTera}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="G"
        selectDenominator="${minimumBinGiga}"
    
    elif [ "$( echo "${numberz} >= ${minimumBinTera}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="T"
        selectDenominator="${minimumBinTera}"
    
    else 
        selectUnitLetter=""
        selectDenominator="1"
fi

selectValue=`printf "%.${decimalPlaces}f\n" "$( echo "scale=12;
${numberz} / ${selectDenominator}" | bc -l)"`

selectValue="$(bash "${winx2unix}" "${selectValue}")"

echo "${selectValue}${selectUnitLetter}"

# test
