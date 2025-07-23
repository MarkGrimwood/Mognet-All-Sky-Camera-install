#!/bin/bash

# Get which period of time we're handling. If it's not specified as night then we assume it's day
PERIOD=${1}
if [ "$PERIOD" != "night" ]; then
  PERIOD="day"
fi

# Wait until the capture script has finished. And don't clash with another instance of this script
while [ true ]; do
  COUNTCAPTURE=$(ps -ef | grep capture | grep bash | wc -l)
  COUNTNEW=$(ps -ef | grep newmovie | grep bash | wc -l)

  echo "capture: $COUNTCAPTURE newmovie: $COUNTNEW"

  if [ "$COUNTCAPTURE" -eq 0 ] && [ "$COUNTNEW" -le 2 ]; then
    break
  fi

  sleep 5s
done
echo "Working"

WORKPATH="/home/pi/Mognet-All-Sky-Camera/back-end/pics"
WEBPATH="/var/www/html"
STANDARDCAPTURE="$WORKPATH/webcam.jpg"

DATESTAMP=$(date +'%s')
HUMANDATE=$(date +'%c')
HUMANTIME=$(date +'%H%M')

echo $HUMANDATE

if [ "$PERIOD" == "day" ]; then
  THISMOVIE="movieday.mp4"
  ADDMOVIE="movieaddday.mp4"
  MOVIELIST="daylist.txt"
  WEBCAMPD="webcamday$DATESTAMP-$HUMANTIME"
else
  THISMOVIE="movienight.mp4"
  ADDMOVIE="movieaddnight.mp4"
  MOVIELIST="nightlist.txt"
  WEBCAMPD="webcamnight$DATESTAMP-$HUMANTIME"
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
for ITEM in $(ls $WORKPATH/webcam*.jpg)
do
  sudo rm "$ITEM"
done

sleep 5s

echo "Initial capture"
convert -size 1440x1080 canvas:black webcam.jpg

if [ "$PERIOD" == "day" ]; then
  # Capture the day image
#  raspistill -ISO auto -awb greyworld --nopreview --exposure auto -w 1440 -h 1080 -o "$STANDARDCAPTURE
  rpicam-still --autofocus-mode manual --lens-position 0.0 --nopreview --exposure normal --width 1440 --height 1080 -o "$STANDARDCAPTURE"
else
  # Capture the night image. Although set to 10 seconds it takes closer to 20 on the Pi Zero
#  raspistill -ISO auto -awb greyworld --nopreview --exposure off --stats -w 1440 -h 1080 --contrast 20 -ag 12.0 -dg 2.0 -ss 10000000 -o "$STANDARDCAPTURE"
  rpicam-still --autofocus-mode manual --lens-position 0.0 --nopreview --exposure normal --width 1440 --height 1080 --contrast 20 --gain 20.0 --shutter 10000000 --awbgains 1.1,2.8 --immediate -o "$STANDARDCAPTURE"
fi

ls -lh "$WORKPATH"

# Stamp the image with the date and time and put it into the web day directory along with the thumbnail
echo "Add text and create thumbnail"
convert "$STANDARDCAPTURE" -gravity North -pointsize 30 -fill black -draw "text 2,2 '$IMAGE_TEXT'" -fill white -draw "text 0,0 '$IMAGE_TEXT'" "$WORKPATH/$WEBCAMPD.jpg"
convert -resize 80x60 "$WORKPATH/$WEBCAMPD.jpg" "$WEBPATH/$PERIOD/thumb$WEBCAMPD.jpg"
sudo chown nobody "$WORKPATH/$WEBCAMPD.jpg"
sudo chown nobody "$WEBPATH/$PERIOD/thumb$WEBCAMPD.jpg"

ls -lh "$WORKPATH"

# Copy the captured image for web display too
cp -f "$WORKPATH/$WEBCAMPD.jpg" "$WEBPATH/webcam.jpg"
sudo chown nobody "$WEBPATH/webcam.jpg"

# A new movie seems to need multiple frames
echo "Make copies for initial movie"
cp "$WORKPATH/$WEBCAMPD.jpg" "$WORKPATH/$WEBCAMPD-A.jpg"
cp "$WORKPATH/$WEBCAMPD.jpg" "$WORKPATH/$WEBCAMPD-B.jpg"
cp "$WORKPATH/$WEBCAMPD.jpg" "$WORKPATH/$WEBCAMPD-C.jpg"
cp "$WORKPATH/$WEBCAMPD.jpg" "$WORKPATH/$WEBCAMPD-D.jpg"

# Remove the old movie
echo "Removing old movie"
sudo rm -f "$WORKPATH/$THISMOVIE"

# Make a new movie with these captures
echo "Creating movie"
ffmpeg -y -framerate 10 -pix_fmt yuv420p -pattern_type glob -i "$WORKPATH/webcam$PERIOD*.jpg" -c:v libx264 "$WORKPATH/$THISMOVIE" 

ls -lh "$WORKPATH"

# Copy for web display
echo "Copy for web display"
cp -f "$WORKPATH/$THISMOVIE" "$WEBPATH/$PERIOD/$THISMOVIE"
sudo chown nobody "$WEBPATH/$PERIOD/$THISMOVIE"

# Clean up ready for next time
echo "Clean up"
mv -f "$WORKPATH/$WEBCAMPD.jpg" "$WEBPATH/$PERIOD/"
rm -f "$WORKPATH/$WEBCAMPD-A.jpg"
rm -f "$WORKPATH/$WEBCAMPD-B.jpg"
rm -f "$WORKPATH/$WEBCAMPD-C.jpg"
rm -f "$WORKPATH/$WEBCAMPD-D.jpg"

echo $(date +'%c')
echo "Completed"
