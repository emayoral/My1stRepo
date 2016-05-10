#!/bin/bash
Path2Convert=$1 ;
Path4Dest=$2 ;
MP3FileName=""
OrigExt="mp3"
#pushd "$Path2Convert"
find "$Path2Convert" -type f -iname \*.${OrigExt} -print0 |
while IFS= read -rd '' MP3FileName 
   do
   #echo "$MP3FileName"
   EscapedMP3FileName="$(printf '%q' "$MP3FileName")"
   mybasename="$(basename "$MP3FileName" ".${OrigExt}")"
   mydirname="$(echo $(dirname "$MP3FileName")/ | sed "s@${Path2Convert}@@")"
   #echo $mydirname
   AACFileName="${Path4Dest}${mydirname}${mybasename}.m4a" ;
   EscapedAACFileName=$(printf '%q' "$AACFileName")
   echo "########### \"$MP3FileName\" -> \"$AACFileName\"" ;
   if [[ ! (-e "$AACFileName") ]] ;
      then
      mkdircommand="mkdir -p \"${Path4Dest}${mydirname}\""
      echo $mkdircommand
      #ffmpegcommand="ffmpeg -i \"${MP3FileName}\" -y -vn -loglevel error -map_metadata 0:g  -c:a libfdk_aac -profile:a aac_he_v2 -vbr 3 -movflags +faststart \"$AACFileName\" " ;
      ffmpegcommand="ffprobe -v 0 -of json -show_format \"${MP3FileName}\" > /tmp/tags.json ;  ffmpeg -i \"${MP3FileName}\" -f wav - | fdkaac -p 29 -m 3 -a 1 -G 2 - -o  \"$AACFileName\" --tag-from-json=/tmp/tags.json?format.tags" ;
      echo $ffmpegcommand
      #ffmpeg -i "${MP3FileName}" -y -loglevel error -map_metadata 0:g  -c:a libfdk_aac -profile:a aac_he_v2 -vbr 3 -movflags +faststart "$AACFileName"
      fi
   done 
#popd
