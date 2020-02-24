#!/bin/bash

#
# 1) This scripts search all image and video files on the current folder and recursively.
# 2) All files will be sorted into folders, which names are the date of the files in that folder.
#


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Include xmp files, as they are sidecar files for images and videos.
for file in $( find . -type f -iregex '^.*\.xmp\|^.*\.JPG\|^.*\.JPEG\|^.*\.NEF\|^.*\.DNG\|^.*\.CR2\|^.*\.AVI\|^.*\.MP4\|^.*\.MOV\|^.*\.3GP' | sort )
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
