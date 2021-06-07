#!/bin/bash

# Update the timing
cd /home/pi/Mognet-All-Sky-Camera/back-end/
sudo ./mgasc.sh

sudo cat mgasccron

cd pics/
./spaceclear.sh
