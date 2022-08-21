#!/bin/bash

# Description:
#+ Converts all MP4 videos that are on the same folder as this script,
#+ to HEVC MP4s.
#+ It generates thumbnails, for each video, inside folder "${thumbFolder}".
#+ It attaches each thumbnail to the corresponding HEVC MP4.
#+ Each finished HEVC MP4 is moved to folder "${final_HEVCfolder}"

# INPUTS: videos 

# OUTPUT: MP4 videos

# OUTPUT FORMAT: MP4 videos (HEVC MP4s created inside folder "${final_HEVCfolder}")

# HOW TO RUN example: bash "thisScript.sh" "$targetFolder"


# Assign script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


externalScriptsFolder="scripts"

# External script's folder path
externalScriptsFolder_Path="${scriptDirectoryPath}/${externalScriptsFolder}"


# Import external scripts to use in this script
conv2BinUnits_KMGT="${externalScriptsFolder_Path}/conv2BinUnit+K+M+G+T(-number-decimalPlaces).sh"

conv2DecUnit_KMGT="${externalScriptsFolder_Path}/conv2DecUnit+K+M+G+T(-number-decimalPlaces).sh"

getMediaDurationSexag="${externalScriptsFolder_Path}/ffprobe-mediaLength_sexagesimal(-i).sh"

getMediaDurationSecs="${externalScriptsFolder_Path}/ffprobe-mediaLength_seconds(-i).sh"

getMediaSizeBytes="${externalScriptsFolder_Path}/ffprobe-mediaSize_bytes(-i).sh"

        # streamsLetters: v for vid, a for aud & s for subtitle streams
getStreamBitrate="${externalScriptsFolder_Path}/ffprobe-or-estimate-StreamBitrate(-streamSpecifier-i)(ver.02).sh"


scriptFullPath="$(realpath "$0")"
scriptFullName="${scriptFullPath##*/}"
scriptName="${scriptFullName%.*}"

#create thumbnail folder
thumbFolder="thumbs"
mkdir "${thumbFolder}"

#create "${initial_HEVCfolder}" folder for transcHevc vids
initial_HEVCfolder="initial-hevc"
mkdir "${initial_HEVCfolder}"

# Create "${final_HEVCfolder}" folder for finished HEVC vids
final_HEVCfolder="final-HEVC"
mkdir ${final_HEVCfolder}

# Assign progress_Report text to a variable
progress_Report="progREPORT-${scriptName}.txt"

# Delete previous progress_Report text file 
if [[ -f "${progress_Report}" ]]; then
    
    rm -f "${progress_Report}"
fi

# create new progress_Report text file 
touch "${progress_Report}"

#..................<REPORT>....................................
(echo "......SCRIPT: ${scriptName}...INITIATED......
   ") >> "${progress_Report}"

echo "..
..
..
................SCRIPT: ${scriptName} INITIATED........
..
.."
#.................</REPORT>.....................................


# Number each video
itemid=1

targetFolder="$1" # the folder containing the video(s) of interest

targetFolder_Path="$(realpath "${targetFolder}")"

#..................<REPORT>....................................
    
    echo "Target Folder: ["${targetFolder_Path}"]
        
        "
    
    echo "Target Folder: ["${targetFolder_Path}"]
        " >> "${progress_Report}"
    
#..................<REPORT>....................................
    

# $thumbnailFactor: ratio of the time at which thumbnail 
#+ is captured to the total time of the video.
thumbnailFactor=11/115  

qscaleVid=22 # set qscaleVid value for thumbnail

for i in ${targetFolder}/*.{webm,mp4,ts,mpeg,m2t,flv,mov,avi,wmv}
  do
  
    #get each video (item) name
    itemfullpath="$(realpath "${i}")"
    itemfullname="${itemfullpath##*/}"
    itemname="${itemfullname%.*}"
    extn="${itemfullname##*.}"
    

# If ${itemfullpath} exist, 
#+ proceed with the rest of the script
if [[ -f "${itemfullpath}" ]]; then

#..................<REPORT>....................................
    
    echo "media: ["${itemfullname}"]" >> "${progress_Report}"
    
#..................</REPORT>....................................
    
    # get the duration & size of each video
    medialengthSexagesimal="$(bash "${getMediaDurationSexag}" "${itemfullpath}")"
    
    medialengthSecs="$(bash "${getMediaDurationSecs}" "${itemfullpath}")"
    
    medialengthString="${medialengthSecs} secs (${medialengthSexagesimal})"
    
    mediasize="$(bash ${getMediaSizeBytes} "${itemfullpath}")"
    
    # specified v for video stream
    mediaVidBitRate="$(bash ${getStreamBitrate} v "${itemfullpath}")"
    
    mediaVidBitRate_Units="$(bash "${conv2DecUnit_KMGT}" "${mediaVidBitRate}" 4)"
    
    # specified a for audio stream
    mediaAudBitRate="$(bash ${getStreamBitrate} a "${itemfullpath}")"
    
    mediaAudBitRate_Units="$(bash "${conv2DecUnit_KMGT}" "${mediaAudBitRate}" 4)"
    
    
    mediasize_Units="$(bash "${conv2BinUnits_KMGT}" "${mediasize}" 4)"
    mediasize_String="${mediasize_Units}B"

#..................<REPORT>....................................

    echo "          Duration: ${medialengthString}" >> "${progress_Report}"
    
    echo "          Size: ${mediasize_String}" >> "${progress_Report}"
    
    echo "          Vid-stream Bitrate: ${mediaVidBitRate_Units}b/s" >> "${progress_Report}"
    
    echo "          Aud-stream Bitrate: ${mediaAudBitRate_Units}b/s" >> "${progress_Report}"
    
    echo "      Item-No.: $itemid
    " >> "${progress_Report}"
    
    echo "      getThumb( ) STARTED" >> "${progress_Report}"
    
    echo ".
    .........getThumb( ) STARTED........
    ." 
#..................</REPORT>....................................

    # getThumb(-ss):
    
        #Assign values to variables for capturing thumbnails
    seekTimeThumb=`printf "%.5f\n" $(echo "scale=8;
    $medialengthSecs * $thumbnailFactor" \
    | bc -l)`
    
    ss1stThumb=`printf "%.10f\n" $(echo "scale=10;
    $seekTimeThumb * 0.99999" \
    | bc -l)`
    
    ss2ndThumb=`printf "%.10f\n" $(echo "scale=10;
    $seekTimeThumb - $ss1stThumb" \
    | bc -l)`
    
    thumbnailFullPath="${thumbFolder}/${itemname}-thumbnail.jpg"
    
#..................<REPORT>....................................
    echo "        ( -ss = ${seekTimeThumb} | -q:v = ${qscaleVid} )" >> "${progress_Report}"
#..................</REPORT>....................................
 
 
    #The getThumb() ffmpeg code
    ffmpeg -ss ${ss1stThumb} \
    -i "${itemfullpath}" \
    -ss ${ss2ndThumb} \
    -vframes 1 -c mjpeg -q:v ${qscaleVid} \
    -y "${thumbnailFullPath}"


#..................<REPORT>....................................
    echo "      getThumb( ) COMPLETED
      " >> "${progress_Report}"
    
    
    echo "      transHEVC( ) STARTED" >> "${progress_Report}"
    
    echo ".
    ..........transHEVC( ) STARTED......
    ."
#..................</REPORT>....................................
    
    
    crfValue=-1
    
    presetValue="medium" #Alts: "ultrafast" "superfast" "medium"
    
    vidQualityControl="-vf scale=iw:ih -crf ${crfValue}"
    
    initial_HEVCfullPath="${initial_HEVCfolder}/${itemname}-initialHEVC.mp4"
    
    
    # transHEVC( ).bat ( NB: trailing '?' is added to a -map value 
    # to cause ffmpeg to ignore any instance where the specified 
    # stream doesn't exist in the input )
    ffmpeg -i "${itemfullpath}" \
    -c:v hevc ${vidQualityControl} \
    -c:a aac -q:a 0 -c:s mov_text \
    -metadata:s:s:0 language=eng \
    -map 0:v -map 0:a? -map 0:s? \
    -preset ${presetValue} \
    -y "${initial_HEVCfullPath}"
    
    #..................<REPORT>....................................
    echo "..
    ............Calculating midOutput DETAILS..........
    .."
    #..................</REPORT>....................................
    
    midOutput="${initial_HEVCfullPath}"
    
    midOutputDurationSecs="$(bash ${getMediaDurationSecs} "${midOutput}")"
    midOutputDurationSexag="$(bash ${getMediaDurationSexag} "${midOutput}")"
    
    midOutputDurationString="${midOutputDurationSecs} secs (${midOutputDurationSexag})"
    
    midOutputSizeBytes="$(bash ${getMediaSizeBytes} "${midOutput}")"
    midOutputSize_Units="$(bash "${conv2BinUnits_KMGT}" ${midOutputSizeBytes} 4)"
    
#..................<REPORT>....................................
    echo "        Mid-Output Duration: ${midOutputDurationString}" >> "${progress_Report}"
    
    echo "        Mid-Output Size: ${midOutputSize_Units}B" >> "${progress_Report}"
    
    echo "      transHEVC( ) COMPLETED
      " >> "${progress_Report}"
 
    echo "      attachThumb( ) STARTED" >> "${progress_Report}"
    
    echo ".
    .........attachThumb( ) STARTED.........
    ." 
#..................</REPORT>....................................

    final_HEVCfullPath="${final_HEVCfolder}/${itemname}-HEVC.mp4"

    # attachThumb( ):
    ffmpeg \
    -i "${initial_HEVCfullPath}" \
    -i "${thumbnailFullPath}" \
    -map 0 -map 1 \
    -c:v:0 copy -c:a copy -c:s copy \
    -c:v:1 copy -disposition:v:1 attached_pic \
    -y "${final_HEVCfullPath}"
    
    #..................<REPORT>....................................
    echo "..
    ............Calculating finalOutput DETAILS..........
    .."
    #..................</REPORT>....................................
    
    
    finalOutput="${final_HEVCfullPath}"
    
    finalOutputDurationSecs="$(bash ${getMediaDurationSecs} "${finalOutput}")"
    finalOutputDurationSexag="$(bash ${getMediaDurationSexag} "${finalOutput}")"
    
    finalOutputDurationString="${finalOutputDurationSecs} secs (${finalOutputDurationSexag})"
    
    finalOutputSizeBytes="$(bash "${getMediaSizeBytes}" "${finalOutput}")"
    finalOutputSize_Units="$(bash "${conv2BinUnits_KMGT}" "${finalOutputSizeBytes}" 4)"
    
    finalOutputVidStreamBitrate="$(bash ${getStreamBitrate} v "${finalOutput}")"
    finalOutputVidStreamBitrate_Unit="$(bash "${conv2DecUnit_KMGT}" "${finalOutputVidStreamBitrate}" 4)"
    
    finalOutputAudStreamBitrate="$(bash ${getStreamBitrate} a "${finalOutput}")"
    finalOutputAudStreamBitrate_Unit="$(bash "${conv2DecUnit_KMGT}" "${finalOutputAudStreamBitrate}" 4)"
    
    finalOutputSubtStreamBitrate="$(bash ${getStreamBitrate} s "${finalOutput}")"
    finalOutputSubtStreamBitrate_Unit="$(bash "${conv2DecUnit_KMGT}" "${finalOutputSubtStreamBitrate}" 4)"
    
    savedMediaSizeBytes=`printf "%.1f\n" "$(echo "scale=4;
    ${mediasize} - ${finalOutputSizeBytes}" | bc -l)"`
    
    savedMediaSizeBytes_absolute="${savedMediaSizeBytes##*-}"
    
    savedMediaSize_Units="$(bash "${conv2BinUnits_KMGT}" "${savedMediaSizeBytes_absolute}" 4)"
    
    
    # If savedMediaSizeBytes is equal to 0, ...
    if [ "$( echo "${savedMediaSizeBytes} == 0" | bc -l)" -eq 1 ]
    then
        savedMediaSizeStatus=""
        
        mediaSizeChangeRatio=1
    
    elif [ "$( echo "${savedMediaSizeBytes} >= 0" | bc -l)" -eq 1 ]
    then
        savedMediaSizeStatus="Decrement in Source Size"
        
        mediaSizeChangeRatio=`printf "%.3f\n" "$( echo "scale=10; 
        ${mediasize} / ${finalOutputSizeBytes}" | bc -l)"`
        
    
    elif [ "$( echo "${savedMediaSizeBytes} <= 0" | bc -l)" -eq 1 ]
    then
        savedMediaSizeStatus="Increment in Source Size"
        
        mediaSizeChangeRatio=`printf "%.3f\n" "$( echo "scale=10; 
        ${finalOutputSizeBytes} / ${mediasize}" | bc -l)"`
    
    fi
    
    
#..................<REPORT>....................................
    echo "        Final Output: " >> "${progress_Report}"
                              
    echo "              Duration: ${finalOutputDurationString}" >> "${progress_Report}"
                              
    echo "              Vid. stream Bitrate: ${finalOutputVidStreamBitrate_Unit}b/s" >> "${progress_Report}"
    
    echo "              Aud. stream Bitrate: ${finalOutputAudStreamBitrate_Unit}b/s" >> "${progress_Report}"
    
    echo "              Subt. stream Bitrate: ${finalOutputSubtStreamBitrate_Unit}b/s" >> "${progress_Report}"
    
    echo "              Size: ${finalOutputSize_Units}B" >> "${progress_Report}"
    
    echo "        Change in Size: ${savedMediaSize_Units}B (${mediaSizeChangeRatio}x ${savedMediaSizeStatus})" >> "${progress_Report}"
    
    echo "      attachThumb( ) COMPLETED 
      " >> "${progress_Report}"
#..................</REPORT>....................................
    
   itemid=$((itemid+1))
  
  
    else
        # Else, ${itemfullpath} doesn't exit
        echo "        ${itemfullname} NOT FOUND."
        sleep 0.02
    fi
  
  done
  
  # Remove temporary folders:
  rm -rf "${thumbFolder}"
  
  rm -rf "${initial_HEVCfolder}"
  
  
#..................<REPORT>....................................
echo "......SCRIPT: ${scriptName}...ENDED......" >> "${progress_Report}"

echo ".
.
............SCRIPT: ${scriptName}....ENDED............
..
.."
#..................</REPORT>....................................