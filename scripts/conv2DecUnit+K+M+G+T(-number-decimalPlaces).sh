#!/bin/bash

# DESCRIPTION:
# INPUT: numbers & no.of decimalPlaces
# OUTPUT: (string) {via Decimal division}
# format == "converted number""the unit letter"



# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"

# Import external script
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"


numberz="$1"

decimalPlaces="$2"


minimumDecKilo=`printf "%.3f\n" "$( echo "scale=6;1000^1" | bc -l)"`

minimumDecMega=`printf "%.3f\n" "$( echo "scale=6;1000^2" | bc -l)"`

minimumDecGiga=`printf "%.3f\n" "$( echo "scale=6;1000^3" | bc -l)"`

minimumDecTera=`printf "%.3f\n" "$( echo "scale=6;1000^4" | bc -l)"`

if [ "$( echo "${numberz} >= ${minimumDecKilo}" | bc -l)" -eq 1 ] &&  [ "$( echo "${numberz} < ${minimumDecMega}" | bc -l)" -eq 1 ]
    then 
        selectUnitLetter="K"
        selectDenominator="${minimumDecKilo}"
    
    elif [ "$( echo "${numberz} >= ${minimumDecMega}" | bc -l)" -eq 1 ] && [ "$( echo "${numberz} < ${minimumDecGiga}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="M"
        selectDenominator="${minimumDecMega}"
    
    elif [ "$( echo "${numberz} >= ${minimumDecGiga}" | bc -l)" -eq 1 ] && [ "$( echo "${numberz} < ${minimumDecTera}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="G"
        selectDenominator="${minimumDecGiga}"
    
    elif [ "$( echo "${numberz} >= ${minimumDecTera}" | bc -l)" -eq 1 ]
    then
        selectUnitLetter="T"
        selectDenominator="${minimumDecTera}"
    
    else 
        selectUnitLetter=""
        selectDenominator="1"
fi

selectValue=`printf "%.${decimalPlaces}f\n" "$( echo "scale=12;
${numberz} / ${selectDenominator}" | bc -l)"`

selectValue="$(bash "${winx2unix}" "${selectValue}")"

echo "${selectValue}${selectUnitLetter}"

# test
