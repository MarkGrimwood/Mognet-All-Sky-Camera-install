#!/bin/bash

# Get the passed parameter and the name of this script
THISSCRIPT=${0}
PERIOD=${1}

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
DATESTAMP=$(date +'%s')
HUMANDATE=$(date +'%c')

STANDARDCAPTURE="/run/shm/webcam.jpg"

# Which period of time are we handling? If it's not specified as day then we assume it's night. And set up everything related
if [ "$PERIOD" == "day" ]; then
  FILEFILTER="webcamday*.jpg"
  THISMOVIE="movieday.mp4"
  ADDMOVIE="movieaddday.mp4"
  UPDATEDMOVIE="movieupdatedday.mp4"
  MOVIELIST="daylist.txt"
  WEBCAMPD="webcamday$DATESTAMP.jpg"
else
  PERIOD="night"
  FILEFILTER="webcamnight*.jpg"
  THISMOVIE="movienight.mp4"
  ADDMOVIE="movieaddnight.mp4"
  UPDATEDMOVIE="movieupdatednight.mp4"
  MOVIELIST="nightlist.txt"
  WEBCAMPD="webcamnight$DATESTAMP.jpg"
fi

CPU_TEMP_FULL=$(vcgencmd measure_temp)
CPU_TEMP=${CPU_TEMP_FULL:5:${#CPU_TEMP_FULL}-7}${CPU_TEMP_FULL: -1}
IMAGE_TEXT="$HUMANDATE : CPU Temp $CPU_TEMP"

# Make sure we don't clash with an already running newmovie or instance of this script
COUNTCAPTURE=$(ps -ef | grep "$THISSCRIPT" | grep bash | wc -l)
COUNTNEW=$(ps -ef | grep newmovie | grep bash | wc -l)
if [ "$COUNTCAPTURE" -le 2 ] && [ "$COUNTNEW" -le 1 ]
then
  # Set the workpath
  cd $WORKPATH

  if [ "$PERIOD" == "day" ]; then
    # Capture the day image
    raspistill -ISO auto -awb greyworld -n -ex auto -w 1440 -h 1080 -o "$STANDARDCAPTURE"
  else
    # Capture the night image. Although set to 10 seconds (I think), it takes 75 seconds on a Pi Zero
    raspistill -ISO auto -awb auto -n -ex night -w 1440 -h 1080 -co 70 -ag 9.0 -dg 2.0 -ss 10000000 -o "$STANDARDCAPTURE"
  fi

  # Add date and time stamp
  convert "$STANDARDCAPTURE" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WEBCAMPD"
  cp "$WEBCAMPD" "$WEBPATH/webcam.jpg"
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
