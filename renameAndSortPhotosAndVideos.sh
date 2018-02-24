#!/bin/bash

#
# 1) This scripts search all image and video files on the current folder and recursively.
# 2) Then, all files will be renamed using the creation time stamp found by exiv2 or ffprobe.
# 3) All files will be sorted into folders, which names are the date of the files in that folder.
#


# Check if dependecy command exists
command -v exiv2 >/dev/null 2>&1 || { echo >&2 "I require exiv2 but it's not installed.  Aborting."; exit 1; }
command -v exiftool >/dev/null 2>&1 || { echo >&2 "I require exiftool but it's not installed.  Aborting."; exit 1; }


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

num=`find . -type f -iregex '^.*\.JPG\|^.*\.JPEG\|^.*\.PNG\|^.*\.NEF\|^.*\.CR2' | wc -l`
if [ $num != "0" ]; then
  find . -type f -iregex '^.*\.JPG\|^.*\.JPEG\|^.*\.PNG\|^.*\.NEF\|^.*\.CR2' -print0 | xargs -0 exiv2 -F -r'%Y-%m-%d_%H%M%S' rename
fi


for file in $( find . -type f -iregex '^.*\.AVI' )
do
  time_stamp=$(exiftool -dateFormat "%Y-%m-%d %H:%M:%S" "$file" | grep "Create Date" | head -n1 | cut -d: -f2-)
  ts=$(date -d "$time_stamp + 1 hour" +"%Y-%m-%d_%H%M%S")
  mv "$file" "$ts.AVI"
done


for file in $( find . -type f -iregex '^.*\.MP4' )
do
  time_stamp=$(exiftool -dateFormat "%Y-%m-%d %H:%M:%S" "$file" | grep "Create Date" | head -n1 | cut -d: -f2-)
  ts=$(date -d "$time_stamp + 1 hour" +"%Y-%m-%d_%H%M%S")
  mv "$file" "$ts.mp4"
done


for file in $( find . -type f -iregex '^.*\.MOV' )
do
  time_stamp=$(exiftool -dateFormat "%Y-%m-%d %H:%M:%S" "$file" | grep "Create Date" | head -n1 | cut -d: -f2-)
  ts=$(date -d "$time_stamp + 1 hour" +"%Y-%m-%d_%H%M%S")
  mv "$file" "$ts.mov"
done


for file in $( find . -type f -iregex '^.*\.3GP' )
do
  time_stamp=$(exiftool -dateFormat "%Y-%m-%d %H:%M:%S" "$file" | grep "Create Date" | head -n1 | cut -d: -f2-)
  ts=$(date -d "$time_stamp + 1 hour" +"%Y-%m-%d_%H%M%S")
  mv "$file" "$ts.3gp"
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
