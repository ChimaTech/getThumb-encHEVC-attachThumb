#!/bin/bash

# Assign this script's absolute path to a variable
scriptAbsolutePath="$(realpath $0)"

# Assign this script's directory path to a variable
scriptDirectoryPath="$(dirname "${scriptAbsolutePath}")"


# Import external script
#+ winx2unix: script converts a dos-style-ended string
#+ to a unix-style-ended strings
winx2unix="${scriptDirectoryPath}/winx2unix(string).sh"

calcMediaTotalBitrate="${scriptDirectoryPath}/calculate-mediaTotalBitrate(-i-decimaPlaces)(ver.01).sh"

getAudSampleRateHz="${scriptDirectoryPath}/ffprobe-AudSampleRateHz(-i).sh"

# ******* End of shells-dependencies

scriptFullPath="$0"
scriptFullName="${scriptFullPath##*/}"
scriptName="${scriptFullName%.*}"

# tempFolder, create it when needed
tempFolder="${scriptName}"

#Assign the target media to a variable
stream="$1" # specify stream as v for video, a for audio, s for subtitle
media="$2"

mediaFullName="${media##*/}"
mediaName="${mediaFullName%.*}"
extn="${mediaFullName##*.}"

streamLetterForVideo="v"

streamLetterForAudio="a"

streamLetterForSubtitle="s"

testRegex="[0-9]{1,}$" # match [0-9] = 0 to 9
#                              {1,} = 1 or more times
#                              $ = end of line (i.e. DON'T match anything else)

# IF $inputMedia exists,...
if [[ -f "${media}" ]]; then

# media exists, therefore do:


    if [ "${stream}" = "${streamLetterForVideo}" ] || [[ "$1" =~ v:${testRegex} ]]; then
        #echo "Stream is VIDEO"
        if [ "${stream}" = "${streamLetterForVideo}" ]; then
           
           
           streamSpecifier="${stream}:0"
           
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
        
        elif [[ "${stream}" =~ v:${testRegex} ]]; then
           
           streamSpecifier="${stream}"
           
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
            
        fi
        
        # Since the original variable may contain a decimal point
        #+ and bash,by default, doesn't accept float points,
        #+ assign & combine parts of the original variable
        #+ that come b4 & after decimal point to a new variable "numb"
        
        numb="${mediaStreamBitRate%.*}${mediaStreamBitRate##*.}"
        
        # [ -n "$numb" ] = checks if $numb is NOT NULL
        
        # [ "$numb" -eq "$numb" ] = is an Integer Comparison syntax, hence returns
        #+ an error msg, if $numb is NOT an Integer, that's redirected away from
        #+ the console using 2>/dev/null and
        #+ it is therefore equivalent to saying "is an INTEGER".
        
        if [ -n "$numb" ] && [ "$numb" -eq "$numb" ] 2>/dev/null; then
          #echo "number"
          
          selectStreamBitrate="${mediaStreamBitRate}"
          
        else
          #echo "not a number"
          
          # check if it has audio by using getAudSampleRateHz
          mediaAudioSampleRate=$(bash "${getAudSampleRateHz}" "${media}")
          
          absoluteMediaAudioSampleRate=`printf "%.0f\n" "$(echo "scale=1;
          ${mediaAudioSampleRate}" | bc -l)"`
          
          if [ "${absoluteMediaAudioSampleRate}" -gt 0 ]; then
          
              # [means: it has audio stream]
              
              # stream-copy video stream
              
              tempFolder="${scriptName}"
              mkdir "${tempFolder}"
              
              tempMediaFullPath="${tempFolder}/tempVid.${extn}"
              
              ffmpeg -i "${media}" -an -sn -map 0:${streamSpecifier} -c copy -y "${tempMediaFullPath}"
              
              # check whether the tempMediaFullPath was created succesfully
              # IF $tempMediaFullPath exits,...
              if [[ -f "${tempMediaFullPath}" ]]; then
                    
                  # the tempMediaFullPath file exists
                  tempBitrate="$(bash "${calcMediaTotalBitrate}" "${tempMediaFullPath}" 3)"
                    
                  estimatedVidBitrate=`printf "%.3f\n" "$( echo "scale=5;
                  ${tempBitrate}" | bc -l)"`
                  
                  selectStreamBitrate="${estimatedVidBitrate}"
                  
                  rm -rf "${tempFolder}" # delete the tempFolder
                
                else
                    # the tempMediaFullPath does not exist
                    selectStreamBitrate=0
              
              fi
              
              
          elif [ "${absoluteMediaAudioSampleRate}" -le 0 ]; then
              #[means: it does not have any substantial audio stream]
              # only video stream exists
              
              mediaTotalBitrate="$(bash "${calcMediaTotalBitrate}" "${media}" 3)"
              
              estimatedVidBitrate=`printf "%.3f\n" "$( echo "scale=5;
              ${mediaTotalBitrate}" | bc -l)"`
              
              selectStreamBitrate="${estimatedVidBitrate}"
          
          fi
          
        fi
        
    elif [ "${stream}" = "${streamLetterForAudio}" ] || [[ "$1" =~ a:${testRegex} ]] ;
    then
        #echo " Stream is AUDIO"
        
        if [ "${stream}" = "${streamLetterForAudio}" ]; then
        
            streamSpecifier="${stream}:0"
            
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
        
        elif [[ "${stream}" =~ a:${testRegex} ]]; then
            
            streamSpecifier="${stream}"
            
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
        
        fi
        
        
        numb="${mediaStreamBitRate%.*}${mediaStreamBitRate##*.}"
        
        
        if [ -n "$numb" ] && [ "$numb" -eq "$numb" ] 2>/dev/null; then
          #echo "number"
          
          selectStreamBitrate="${mediaStreamBitRate}"
          
        else
          #echo "not a number"
          
          # check if it has audio by using getAudSampleRateHz
          mediaAudioSampleRate=$(bash "${getAudSampleRateHz}" "${media}")
          
          absoluteMediaAudioSampleRate=`printf "%.0f\n" "$(echo "scale=1;
          ${mediaAudioSampleRate}" | bc -l)"`
          
          if [ "${absoluteMediaAudioSampleRate}" -gt 0 ]; then
          
            # [means: it has audio stream]
              
              # stream-copy audio stream
              
              tempFolder="${scriptName}"
              mkdir "${tempFolder}"
              
              tempMediaFullPath="${tempFolder}/tempAud.${extn}"
              
              ffmpeg -i "${media}" -vn -sn -map 0:${streamSpecifier} -c copy -y "${tempMediaFullPath}"
              
              
              # check whether the tempMediaFullPath was created succesfully
              #+ IF tempMediaFullPath exists,...
              if [[ -f "${tempMediaFullPath}" ]]; then
              
                  tempBitrate="$(bash "${calcMediaTotalBitrate}" "${tempMediaFullPath}" 3)"
                  
                  estimatedVidBitrate=`printf "%.3f\n" "$( echo "scale=5;
                  ${tempBitrate}" | bc -l)"`
                  
                  selectStreamBitrate="${estimatedVidBitrate}"
                  
                  rm -rf "${tempFolder}" # delete the tempFolder
                
                else
                    # the tempMediaFullPath does not exist
                    selectStreamBitrate=0
                    
              fi
              
          
          elif [ "${absoluteMediaAudioSampleRate}" -le 0 ]; then
            #[means: it does not have any substantial audio stream]
          
            selectStreamBitrate=0
          
          fi
          
        fi
    
    elif [ "${stream}" = "${streamLetterForSubtitle}" ] || [[ "$1" =~ s:${testRegex} ]];
    then
        #echo " Stream is SUBTITLE"
        
        if [ "${stream}" = "${streamLetterForSubtitle}" ]; then
            
            streamSpecifier="${stream}:0"
            
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
        
        elif [[ "${stream}" =~ s:${testRegex} ]]; then
        
            streamSpecifier="${stream}"
            
            #ffprobe to get the media's video stream bitrate
            mediaStreamBitRate=$(ffprobe -v error \
            -select_streams ${streamSpecifier} -show_entries stream=bit_rate \
            -of default=noprint_wrappers=1:nokey=1 "${media}")
            
            #convert value to unix-style-ended string
            mediaStreamBitRate=$(sh "${winx2unix}" "${mediaStreamBitRate}")
        
        
        fi
        
        numb="${mediaStreamBitRate%.*}${mediaStreamBitRate##*.}"
        
        
        if [ -n "$numb" ] && [ "$numb" -eq "$numb" ] 2>/dev/null; then
          #echo "number"
          
          selectStreamBitrate="${mediaStreamBitRate}"
          
        else
          #echo "not a number"
          
          # check if it has audio by using getAudSampleRateHz
          mediaAudioSampleRate=$(bash "${getAudSampleRateHz}" "${media}")
          
          absoluteMediaAudioSampleRate=`printf "%.0f\n" "$(echo "scale=1;
          ${mediaAudioSampleRate}" | bc -l)"`
          
          if [ "${absoluteMediaAudioSampleRate}" -gt 0 ]; then
          
            # [means: it has audio stream]
              
              # stream-copy subtitle stream
              
              tempFolder="${scriptName}"
              mkdir "${tempFolder}"
              
              tempMediaFullPath="${tempFolder}/tempSubtxt.${extn}"
              
              ffmpeg -i "${media}" -vn -an -map 0:${streamSpecifier} -c copy -y "${tempMediaFullPath}"
              
              
              # check whether the tempMediaFullPath was created succesfully
              #+ IF $tempMediaFullPath exists, ...
              if [[ -f "${tempMediaFullPath}" ]]; then
              
                  tempBitrate="$(bash "${calcMediaTotalBitrate}" "${tempMediaFullPath}" 3)"
                  
                  estimatedVidBitrate=`printf "%.3f\n" "$( echo "scale=5;
                  ${tempBitrate}" | bc -l)"`
                  
                  selectStreamBitrate="${estimatedVidBitrate}"
                  
                  rm -rf "${tempFolder}" # delete the tempFolder
                
                else
                    # the tempMediaFullPath does not exist
                    selectStreamBitrate=0
                    
              fi
              
          elif [ "${absoluteMediaAudioSampleRate}" -le 0 ]; then
            #[means: it does not have any substantial audio stream]
          
            selectStreamBitrate=0
          
          fi
          
        fi
        
    else
        #echo  "Stream is NOT SPECIFIED"
        
        selectStreamBitrate="specify stream using v[:n] for video stream or a[:n] for audio stream or s[:n] for subtitle stream, where n is an integer "
    
    fi

else
    # $inputMedia DOES NOT exist
    selectStreamBitrate="MEDIA [ ${media} ]: NOT FOUND."

fi


# if tempFolder still exist, delete it
rm -rf "${tempFolder}" # delete the tempFolder


echo "${selectStreamBitrate}"

#EXAMPLE: to get the video-stream bit_rate of $inputMedia, call:
# sh $thisScript v $inputMedia
