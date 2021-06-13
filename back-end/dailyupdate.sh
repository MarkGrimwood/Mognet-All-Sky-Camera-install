#!/bin/bash

# Update the timing
cd /home/pi/Mognet-All-Sky-Camera/back-end/
sudo ./mgasc.sh

sudo cat mgasccron

# Ensure there is enough clear space for captures
# - Not sure this one is totally necessary as it's also called in newmovie.sh. Currently left in as there was an occasional problem encountered, and this script reports to a log
cd pics/
./clearspace.sh
