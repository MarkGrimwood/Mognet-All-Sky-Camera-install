#!/bin/bash

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
PERIOD="night"
THISMOVIE="movienight.mp4"
ADDMOVIE="movieaddnight.mp4"
MOVIELIST="nightlist.txt"

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

# Archive last night's files if they exist
[ -d "$WEBPATH/night" ] && mv "$WEBPATH/night" "$WEBPATH/history/$DATESTAMP-night"
mkdir "$WEBPATH/night"
echo "start:$DATESTAMP">"$WEBPATH/night/info"

# Create the nightly file (should really be done with the movie creation)
echo -e "file '"$WORKPATH"/"$THISMOVIE"'\n""file '"$WORKPATH"/"$ADDMOVIE"'\n">"$MOVIELIST"

# Capture the initial night image
#raspistill -ISO auto -awb greyworld -n -ex night -w 1640 -h 1232 -co 70 -ag 9.0 -dg 2.0 -ss 10000000 -o "/run/shm/webcam.jpg"
raspistill -ISO auto -awb greyworld -n -ex night -w 1440 -h 1080 -co 70 -ag 9.0 -dg 2.0 -ss 10000000 -o "/run/shm/webcam.jpg"

# Stamp the image with the date and time and put it into the web night directory along with the thumbnail
convert "/run/shm/webcam.jpg" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WORKPATH/webcamnight$DATESTAMP.jpg"
convert -resize 80x60 "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WEBPATH/night/thumbwebcamnight$DATESTAMP.jpg";

# Copy the captured image for web display too
cp -f "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WEBPATH/webcam.jpg"
sudo chown nobody "$WEBPATH/webcam.jpg"

# A new movie seems to need multiple frames
cp "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WORKPATH/webcamnightA$DATESTAMP.jpg"
cp "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WORKPATH/webcamnightB$DATESTAMP.jpg"
cp "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WORKPATH/webcamnightC$DATESTAMP.jpg"
cp "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WORKPATH/webcamnightD$DATESTAMP.jpg"

# Make a new movie with this last capture
ffmpeg -y -framerate 20 -pix_fmt yuv420p -pattern_type glob -i "$WORKPATH/webcamnight*.jpg" -c:v libx264 "$WORKPATH/$THISMOVIE"

# Copy for web display
cp -f "$WORKPATH/$THISMOVIE" "$WEBPATH/night/$THISMOVIE"
sudo chown nobody "$WEBPATH/night/$THISMOVIE"

# Clean up ready for next time
mv -f "$WORKPATH/webcamnight$DATESTAMP.jpg" "$WEBPATH/night/"
rm "$WORKPATH/webcamnightA$DATESTAMP.jpg"
rm "$WORKPATH/webcamnightB$DATESTAMP.jpg"
rm "$WORKPATH/webcamnightC$DATESTAMP.jpg"
rm "$WORKPATH/webcamnightD$DATESTAMP.jpg"
