#!/bin/bash

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
PERIOD="night"

FILEFILTER="webcamnight*.jpg"
THISMOVIE="movienight.mp4"
ADDMOVIE="movieaddnight.mp4"
UPDATEDMOVIE="movieupdatednight.mp4"
MOVIELIST="nightlist.txt"

DATESTAMP=$(date +'%s')
HUMANDATE=$(date +'%c')

CPU_TEMP_FULL=$(vcgencmd measure_temp)
CPU_TEMP=${CPU_TEMP_FULL:5:${#CPU_TEMP_FULL}-7}${CPU_TEMP_FULL: -1}
IMAGE_TEXT="$HUMANDATE : CPU Temp $CPU_TEMP"

# Make sure we don't clash with an already running capture/add
COUNTCAPTURE=$(ps -ef | grep capture | grep bash | wc -l)
COUNTNEW=$(ps -ef | grep newday | grep bash | wc -l)
if [ "$COUNTCAPTURE" -le 2 ] && [ "$COUNTNEW" -le 1 ]
then
  # Set the workpath
  cd $WORKPATH

  # Capture the night image. Although set to 10 seconds (I think), it takes 75 seconds on a Pi Zero
  raspistill -ISO auto -awb auto -n -ex night -w 1440 -h 1080 -co 70 -ag 9.0 -dg 2.0 -ss 10000000 -o /run/shm/webcam.jpg

  # Add date and time stamp
  convert "/run/shm/webcam.jpg" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "webcamnight$DATESTAMP.jpg"
  cp "webcamnight$DATESTAMP.jpg" "$WEBPATH/webcam.jpg"
  sudo chown nobody "$WEBPATH/webcam.jpg"

  # Get the current list of frame(s) This should avoid dropped frames if this script is activated while an older one is still running
  FILELIST=$(ls $FILEFILTER)

  # Set frame(s) as a new movie
  ffmpeg -y -framerate 20 -pix_fmt yuv420p -pattern_type  glob -i "$FILELIST" -c:v libx264 "$ADDMOVIE"

  # Now we've done with the captured frames make the images immediately available in the night shot list along with thumbnails
  for i in $FILELIST; do convert -resize 80x60 $i thumb$i; done
  mv -f thumb*.jpg $WEBPATH/$PERIOD/
  mv -f $FILELIST $WEBPATH/$PERIOD/

  # Concatenate the current and additional movies into a new one
  ffmpeg -y -f concat -safe 0 -i "$MOVIELIST" -c copy "$UPDATEDMOVIE"

  # Move the new mp4 to replace the old
  mv -f "$UPDATEDMOVIE" "$THISMOVIE"
  cp -f "$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
  sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

  # Clean up ready for next time
  rm $ADDMOVIE
fi
