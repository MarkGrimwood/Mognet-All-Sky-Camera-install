#!/bin/bash

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
PERIOD="day"
THISMOVIE="movieday.mp4"
ADDMOVIE="movieaddday.mp4"
MOVIELIST="daylist.txt"

DATESTAMP=$(date +'%s')
HUMANDATE=$(date +'%c')

CPU_TEMP_FULL=$(vcgencmd measure_temp)
CPU_TEMP=${CPU_TEMP_FULL:5:${#CPU_TEMP_FULL}-7}${CPU_TEMP_FULL: -1}
IMAGE_TEXT="$HUMANDATE : CPU $CPU_TEMP"

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
sudo chown nobody /var/www/html/$PERIOD
echo "start:$DATESTAMP">"$WEBPATH/$PERIOD/info"

# Create the daily file (should really be done with the movie creation)
echo -e "file '"$WORKPATH"/"$THISMOVIE"'\n""file '"$WORKPATH"/"$ADDMOVIE"'\n">"$MOVIELIST"

# Capture the intial day image
raspistill -ISO auto -awb greyworld -n -ex auto -w 1440 -h 1080 -o /run/shm/webcam.jpg

# Stamp the image with the date and time and put it into the web day directory along with the thumbnail
convert "/run/shm/webcam.jpg" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WORKPATH/webcamday$DATESTAMP.jpg"
convert -resize 80x60 "$WORKPATH/webcamday$DATESTAMP.jpg" "$WEBPATH/day/thumbwebcamday$DATESTAMP.jpg";

# Copy the captured image for web display too
cp -f "$WORKPATH/webcamday$DATESTAMP.jpg" "$WEBPATH/webcam.jpg"
sudo chown nobody "$WEBPATH/webcam.jpg"

# A new movie seems to need multiple frames
cp "$WORKPATH/webcamday$DATESTAMP.jpg" "$WORKPATH/webcamdayA$DATESTAMP.jpg"
cp "$WORKPATH/webcamday$DATESTAMP.jpg" "$WORKPATH/webcamdayB$DATESTAMP.jpg"
cp "$WORKPATH/webcamday$DATESTAMP.jpg" "$WORKPATH/webcamdayC$DATESTAMP.jpg"
cp "$WORKPATH/webcamday$DATESTAMP.jpg" "$WORKPATH/webcamdayD$DATESTAMP.jpg"

# Make a new movie with this last capture
ffmpeg -y -framerate 20 -pix_fmt yuv420p -pattern_type glob -i "$WORKPATH/webcamday*.jpg" -c:v libx264 "$WORKPATH/$THISMOVIE"

# Copy for web display
cp -f "$WORKPATH/$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

# Clean up ready for next time
mv -f "$WORKPATH/webcamday$DATESTAMP.jpg" "$WEBPATH/$PERIOD/"
rm "$WORKPATH/webcamdayA$DATESTAMP.jpg"
rm "$WORKPATH/webcamdayB$DATESTAMP.jpg"
rm "$WORKPATH/webcamdayC$DATESTAMP.jpg"
rm "$WORKPATH/webcamdayD$DATESTAMP.jpg"
