#!/bin/bash

# Get which period of time we're handling. If it's not specified as night then we assume it's day
PERIOD=${1}
if [ "$PERIOD" != "night" ]; then
  PERIOD="day"
fi

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
STANDARDCAPTURE="/run/shm/webcam.jpg"

DATESTAMP=$(date +'%s')
HUMANDATE=$(date +'%c')

if [ "$PERIOD" == "day" ]; then
  THISMOVIE="movieday.mp4"
  ADDMOVIE="movieaddday.mp4"
  MOVIELIST="daylist.txt"
  WEBCAMPD="webcamday$DATESTAMP.jpg"
else
  THISMOVIE="movienight.mp4"
  ADDMOVIE="movieaddnight.mp4"
  MOVIELIST="nightlist.txt"
  WEBCAMPD="webcamnight$DATESTAMP.jpg"
fi

CPU_TEMP_FULL=$(vcgencmd measure_temp)
CPU_TEMP=${CPU_TEMP_FULL:5:${#CPU_TEMP_FULL}-7}${CPU_TEMP_FULL: -1}
IMAGE_TEXT="$HUMANDATE : CPU Temp $CPU_TEMP"

# Get the remaining space on the memory card/disk and remove enough history to ensure at least 2G remains
arrDf=($(df --output=avail /))
remainingSpace=${arrDf[1]}
# Size seems to be in K (or blocks of 1024), so 2097152 blocks is the equivalent of 2G
while [ $remainingSpace -lt 2097152 ]; do
  # Select the oldest item for removal
  arrDir=($(ls -rt $WEBPATH/history/))
  # Remove the files from the directory
  sudo rm $WEBPATH/history/${arrDir[0]}/*
  # And then remove the directory
  sudo rmdir $WEBPATH/history/${arrDir[0]}/

  # Get the remaining space on the memory card/disk
  arrDf=($(df --output=avail /))
  remainingSpace=${arrDf[1]}
done

# Archive last day's files if they exist
[ -d "$WEBPATH/$PERIOD" ] && mv "$WEBPATH/$PERIOD" "$WEBPATH/history/$DATESTAMP-$PERIOD"
mkdir "$WEBPATH/$PERIOD"
echo "start:$DATESTAMP">"$WEBPATH/$PERIOD/info"
sudo chown nobody "$WEBPATH/$PERIOD"
sudo chown nobody "$WEBPATH/$PERIOD/info"

# Create the daily file (should really be done with the movie creation)
echo -e "file '"$WORKPATH"/"$THISMOVIE"'\n""file '"$WORKPATH"/"$ADDMOVIE"'\n">"$MOVIELIST"

if [ "$PERIOD" == "day" ]; then
  # Capture the initial day image
  raspistill -ISO auto -awb greyworld -n -ex auto -w 1440 -h 1080 -o "$STANDARDCAPTURE"
else
  # Capture the initial night image
  raspistill -ISO auto -awb greyworld -n -ex night -w 1440 -h 1080 -co 70 -ag 9.0 -dg 2.0 -ss 10000000 -o "$STANDARDCAPTURE"
fi

# Stamp the image with the date and time and put it into the web day directory along with the thumbnail
convert "$STANDARDCAPTURE" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WORKPATH/$WEBCAMPD"
convert -resize 80x60 "$WORKPATH/$WEBCAMPD" "$WEBPATH/$PERIOD/thumb$WEBCAMPD"
sudo chown nobody "$WORKPATH/$WEBCAMPD"
sudo chown nobody "$WEBPATH/$PERIOD/thumb$WEBCAMPD"

# Copy the captured image for web display too
cp -f "$WORKPATH/$WEBCAMPD" "$WEBPATH/webcam.jpg"
sudo chown nobody "$WEBPATH/webcam.jpg"

# A new movie seems to need multiple frames
cp "$WORKPATH/$WEBCAMPD" "$WORKPATH/$WEBCAMPD-A.jpg"
cp "$WORKPATH/$WEBCAMPD" "$WORKPATH/$WEBCAMPD-B.jpg"
cp "$WORKPATH/$WEBCAMPD" "$WORKPATH/$WEBCAMPD-C.jpg"
cp "$WORKPATH/$WEBCAMPD" "$WORKPATH/$WEBCAMPD-D.jpg"

# Make a new movie with this last capture
ffmpeg -y -framerate 20 -pix_fmt yuv420p -pattern_type glob -i "$WORKPATH/$WEBCAMPD" -c:v libx264 "$WORKPATH/$THISMOVIE"

# Copy for web display
cp -f "$WORKPATH/$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

# Clean up ready for next time
mv -f "$WORKPATH/$WEBCAMPD" "$WEBPATH/$PERIOD/"
rm "$WORKPATH/$WEBCAMPD-A.jpg"
rm "$WORKPATH/$WEBCAMPD-B.jpg"
rm "$WORKPATH/$WEBCAMPD-C.jpg"
rm "$WORKPATH/$WEBCAMPD-D.jpg"
