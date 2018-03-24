#!/bin/bash

#
# 1) This scripts search all image and video files on the current folder and recursively.
# 2) Then, all files will be renamed using the creation time stamp found by exiv2 or ffprobe.
# 3) All files will be sorted into folders, which names are the date of the files in that folder.
#


# Check if dependecy command exists
command -v exiv2 >/dev/null 2>&1 || { echo >&2 "I require exiv2 but it's not installed.  Aborting."; exit 1; }
command -v exiftool >/dev/null 2>&1 || { echo >&2 "I require exiftool but it's not installed.  Aborting."; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo >&2 "I require ffprobe but it's not installed.  Aborting."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

num=`find . -type f -iregex '^.*\.JPG\|^.*\.JPEG\|^.*\.PNG\|^.*\.NEF\|^.*\.CR2' | wc -l`
if [ $num != "0" ]; then
  find . -type f -iregex '^.*\.JPG\|^.*\.JPEG\|^.*\.PNG\|^.*\.NEF\|^.*\.CR2' -print0 | xargs -0 exiv2 -F -r'%Y-%m-%d_%H%M%S' rename
fi


# Use:
#  exiftool "-CreateDate=2017:08:11 12:00:00" file.mp4
# to modify UTC time for video
# Check with
#  date -d "2018-02-24T12:32:57.000000Z" +"%Y-%m-%d_%H%M%S"
for file in $( find . -type f -iregex '^.*\.AVI\|^.*\.MP4\|^.*\.MOV\|^.*\.3GP' )
do
  # Get creation time for the video
  time_stamp=$(ffprobe -v quiet -show_streams -show_format -of json "$file"| jq --raw-output '.format.tags | .creation_time')
  #ts=$(date -d "$time_stamp - 1 hour" +"%Y-%m-%d_%H%M%S")
  ts=$(date -d "$time_stamp" +"%Y-%m-%d_%H%M%S")

  filename=$(basename "$file")
  extension="${filename##*.}"

  mv "$file" "$ts.$extension"
done


for file in $( find . -type f -iregex '^.*\.JPG\|^.*\.JPEG\|^.*\.NEF\|^.*\.CR2\|^.*\.AVI\|^.*\.MP4\|^.*\.MOV\|^.*\.3GP' | sort )
do
  # strip directory and suffix from filenames
  fname=`basename $file`

  # Extract the date
  d=`echo $fname | grep -o "[12][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]"`

  if [ ! -d $d ]
  then
    mkdir $d
  fi

  if [ ! -f "$d/$fname" ]
  then
    mv "$file" $d/
  fi
done

IFS=$SAVEIFS

exit 0
