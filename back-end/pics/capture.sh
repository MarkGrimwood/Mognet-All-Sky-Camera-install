#!/bin/bash

# Get the passed parameter and the name of this script
THISSCRIPT=${0}
PERIOD=${1}

# Make sure we don't clash with an already running newmovie or instance of this script
COUNTCAPTURE=$(ps -ef | grep capture | grep bash | wc -l)
COUNTNEW=$(ps -ef | grep newmovie | grep bash | wc -l)
if [ "$COUNTCAPTURE" -le 2 ] && [ "$COUNTNEW" -eq 0 ]
then
  WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
  WEBPATH="/var/www/html"
  DATESTAMP=$(date +'%s')
  HUMANDATE=$(date +'%c')
  HUMANTIME=$(date +'%H%M')

  STANDARDCAPTURE="$WORKPATH/webcam.jpg"

  # Which period of time are we handling? If it's not specified as day then we assume it's night. And set up everything related
  if [ "$PERIOD" == "day" ]; then
    FILEFILTER="webcamday*.jpg"
    THISMOVIE="movieday.mp4"
    ADDMOVIE="movieaddday.mp4"
    UPDATEDMOVIE="movieupdatedday.mp4"
    MOVIELIST="daylist.txt"
    WEBCAMPD="webcamday$DATESTAMP-$HUMANTIME.jpg"
  else
    PERIOD="night"
    FILEFILTER="webcamnight*.jpg"
    THISMOVIE="movienight.mp4"
    ADDMOVIE="movieaddnight.mp4"
    UPDATEDMOVIE="movieupdatednight.mp4"
    MOVIELIST="nightlist.txt"
    WEBCAMPD="webcamnight$DATESTAMP-$HUMANTIME.jpg"
  fi

  CPU_TEMP_FULL=$(vcgencmd measure_temp)
  CPU_TEMP=${CPU_TEMP_FULL:5:${#CPU_TEMP_FULL}-7}${CPU_TEMP_FULL: -1}
  IMAGE_TEXT="$HUMANDATE : CPU Temp $CPU_TEMP"

  # Set the workpath
  cd $WORKPATH

  if [ "$PERIOD" == "day" ]; then
    # Capture the day image
    rpicam-still --autofocus-mode manual --lens-position 0.0 --nopreview --exposure normal --width 1440 --height 1080 -o "$STANDARDCAPTURE" 
 else
    # Capture the night image. Although set to 10 seconds it takes closer to 20 on the Pi Zero
    rpicam-still --autofocus-mode manual --lens-position 0.0 --nopreview --exposure normal --width 1440 --height 1080 --contrast 20 --gain 20.0 --shutter 10000000 --awbgains 1.1,2.8 --immediate -o "$STANDARDCAPTURE"
  fi

  # Add date and time stamp
  convert "$STANDARDCAPTURE" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WEBCAMPD"
  cp "$WEBCAMPD" "$WEBPATH/webcam.jpg"
  sudo chown nobody "$WEBPATH/webcam.jpg"

  # Set frame(s) as a new movie
  ffmpeg -y -framerate 10 -pix_fmt yuv420p -pattern_type  glob -i "$WEBCAMPD" -c:v libx264 "$ADDMOVIE"

  convert -resize 80x60 "$WORKPATH/$WEBCAMPD" "$WEBPATH/$PERIOD/thumb$WEBCAMPD"
  sudo chown nobody "$WEBPATH/$PERIOD/thumb$WEBCAMPD"
  
  mv "$WORKPATH/$WEBCAMPD" "$WEBPATH/$PERIOD/$WEBCAMPD"
  sudo chown nobody "$WEBPATH/$PERIOD/$WEBCAMPD"
  
  # Concatenate the current and additional movies into a new one
  ffmpeg -y -f concat -safe 0 -i "$MOVIELIST" -c copy "$UPDATEDMOVIE"

  # Move the new mp4 to replace the old
  mv -f "$UPDATEDMOVIE" "$THISMOVIE"
  cp -f "$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
  sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

  # Clean up ready for next time
  rm $ADDMOVIE
fi
