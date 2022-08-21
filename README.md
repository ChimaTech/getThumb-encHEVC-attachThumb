
# FFmpeg | Transcode Videos to HEVC and Attach Thumbnails. 

### Input: 
- targetFolder *(containing **videos**, 1st argument)*

### Output: 
- MP4 videos *(.h265)*

### Output Format:
- HEVC MP4 videos (*.h265* MP4s). 

### Description:
The main shell script **main.sh**  converts the videos that are inside the target folder (**targetFolder**) to **HEVC MP4s**.

It generates thumbnails, for each video, and attaches each thumbnail to the corresponding HEVC MP4 video. Each finished HEVC MP4 is moved to the folder **"final-HEVC"**. 

It uses the following file extensions that are listed inside the script to find video files:
- webm
- mp4
- ts
- mpeg
- m2t
- flv
- mov
- avi
- wmv

The list may be expanded to include more video file extensions. 

This shell script also generates a text file to report the transcoding processes. 


### How To Run.
- Example 01: 
```sh
bash "main.sh" "$targetFolder"

```

- Example 02: 
```sh
bash "main.sh" "vid/"
```

- Example 03: *(call the main shell script on a current working directory by using **"./"** ).* 
```sh
bash "main.sh" ./
```
