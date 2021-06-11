#!/bin/bash

# Get which period of time we're handling. If it's not specified as night then we assume it's day
PERIOD=${1}
if [ "$PERIOD" != "night" ]; then
  PERIOD="day"
fi

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
STANDARDCAPTURE="$WORKPATH/webcam.jpg"

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

# Archive last day's files if they exist
if [ -d "$WEBPATH/$PERIOD" ]; then
  echo "$WEBPATH/$PERIOD exists"
  FILECOUNT=$(ls $WEBPATH/$PERIOD | wc -l)
  echo "FILECOUNT is $FILECOUNT"
  if [ $FILECOUNT -gt 4 ]; then
    # But only if there is more than just the base information
    echo "Moving $WEBPATH/$PERIOD"
    mv "$WEBPATH/$PERIOD" "$WEBPATH/history/$DATESTAMP-$PERIOD"
  else
    # Only the base entry is present, so remove ready for recreation
    echo "Removing $WEBPATH/$PERIOD"
    rm -r "$WEBPATH/$PERIOD"
  fi
fi

# Make sure there is enough space on disk for the next capture period
cd $WORKPATH
./clearspace.sh

# And start the new period
echo "Creating $WEBPATH/$PERIOD"
mkdir "$WEBPATH/$PERIOD"
echo "start:$DATESTAMP">"$WEBPATH/$PERIOD/info"
sudo chown nobody "$WEBPATH/$PERIOD"
sudo chown nobody "$WEBPATH/$PERIOD/info"

# Create the daily file (should really be done with the movie creation)
echo -e "file '"$WORKPATH"/"$THISMOVIE"'\n""file '"$WORKPATH"/"$ADDMOVIE"'\n">"$MOVIELIST"

# Make sure there are no old images hanging around before we start
rm "$WORKPATH/*.jpg"

echo "Initial capture"
if [ "$PERIOD" == "day" ]; then
  # Capture the day image
  raspistill -ISO auto -awb greyworld --nopreview --exposure auto -w 1440 -h 1080 -o "$STANDARDCAPTURE"
else
  # Capture the night image. Although set to 10 seconds it takes closer to 20 on the Pi Zero
  raspistill -ISO auto -awb greyworld --nopreview --exposure off --stats -w 1440 -h 1080 --contrast 20 -ag 12.0 -dg 2.0 -ss 10000000 -o "$STANDARDCAPTURE"
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

# Make a new movie with these captures
echo "Creating movie"
ffmpeg -y -framerate 20 -pix_fmt yuv420p -pattern_type glob -i "$WORKPATH/webcam$PERIOD*.jpg" -c:v libx264 "$WORKPATH/$THISMOVIE"

# Copy for web display
cp -f "$WORKPATH/$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

# Clean up ready for next time
mv -f "$WORKPATH/$WEBCAMPD" "$WEBPATH/$PERIOD/"
rm "$WORKPATH/$WEBCAMPD-A.jpg"
rm "$WORKPATH/$WEBCAMPD-B.jpg"
rm "$WORKPATH/$WEBCAMPD-C.jpg"
rm "$WORKPATH/$WEBCAMPD-D.jpg"
