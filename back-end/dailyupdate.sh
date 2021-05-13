#!/bin/bash

# Update the timing
cd /home/pi/Mognet-All-Sky-Camera/back-end/
sudo ./mgasc.sh>update.log

# Ensure we're up to date
sudo apt-get -y update>>update.log
sudo apt-get -y upgrade>>update.log
sudo apt-get clean>>update.log
sudo apt-get autoclean>>update.log
sudo apt-get autoremove>>update.log
