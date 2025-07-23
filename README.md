# All Sky Camera code for the Raspberry Pi

This project was created as a minimum viable product for all sky camera software that would handle backend capture automatically and provide a front end to display the image along with videos and saved image history while also being lightweight enough to run on a Raspberry Pi Zero W without stress. It is based on a previous all sky camera by Pete https://github.com/rederikus/AllSky-Camera-Raspberry-Pi and also contains the SunWait executable from https://github.com/risacher/sunwait

The code sets up a cron job to capture an image once per minute day and night. Each image is date and timestamped, and appended to an Mpeg for the relevant period. The saved periods are archived until the memory card is almost full, at which point the oldest period is deleted. At noon every day the crontab file is regenerated for the changing sunrise and sunset times. 

Full documentation is available in the Wiki https://github.com/MarkGrimwood/Mognet-All-Sky-Camera-install/wiki And I've started a discussion thread here https://stargazerslounge.com/topic/376932-another-all-sky-camera/

# Quick Setup Guide

## Before installation

You will need to know your latitude and longitude. An approximate location is fine as this information is only used for timings of sunrise, sunset etc. The values are entered separately in decimal format with the N/S and E/W indicators. Those values will be truncated to two decimal points, so a precise location of 52.202175N, 0.128179E will become 52.20N and 0.12E

## Installation

Initialise the memory card with a 32-bit version of Raspbian. For the RPi Zero Raspbian Lite is probably the best version to go for
Set up on the card for wifi and ssh
Then assemble the RPi, camera and power supply, insert the card and turn it on. Give it a couple minutes to sort itself out. Don't forget to do the standard updates as per https://www.raspberrypi.org/documentation/raspbian/updating.md

Once it's ready, SSH onto the RPi to do the rest of the setup
First up configure it for camera use, set the host name, and change the password
Enter sudo raspi-config at the prompt
* Go to System Options->Hostname and give it the name you want your pi to be known as
* Now go to System Options->Password and change the password away from the default. Make sure it's something you can remember
* And then enable the camera in Interface Options->Camera

Select Finish, and reboot the RPi if required

Now to get the code onto the RPi and install it, so type the following commands
* wget https://github.com/MarkGrimwood/Mognet-All-Sky-Camera-install/archive/refs/heads/main.zip
* unzip main.zip
* cd Mognet-All-Sky-Camera-install-main/
* chmod 755 autodeploy
* ./autodeploy
 
You will be prompted for your latitude and longitude, and then after that everything should automatic. Once complete the installer script will give the URL for viewing the captured images, etc and viewing is just through a normal web browser 

The install directory and zip file can now be removed:
* cd ~/
* rm -r Mognet-All-Sky-Camera-install-main/
* rm main.zip

# Version History

## v1.27 - 23rd July 2025

* Fix to use V3 camera and rpicam-still
* Fix daylight saving time handling bug in shotlist.php
* Improve display in shotlist.php
* Fix first time period bug in index.php
* Cater for occasional failed image capture in newmovie.sh

## v1.2.6 - 13th October 2021

* Fix minor bug in new movie file clearance

## v1.2.5 - 21st July 2021

* Minor update to add version numbers to autodeploy and install scripts, version history in README.md and add cleanup after install instructions

## v1.2.4

* Fix reliability issue on creating new movies when system is running slow

## v1.2.3

* Fix jpg naming and clearance defect introduced in v.1.2.2

## v1.2.2

* Move history clearance to a common script
* Fix potential infinite loop in history clearance
* Fix removal of empty history directory when using memory cards under the minimum required size
* Remove surplus .jpg files from pics/ directory before creating a new period movie
* Improve image capture at night

## v1.2.1

* Change nighttime captures so that capture can happen once per minute with the right cameras instead of every two minutes

## v1.2

* Fix history creation where an unused period containing only the initial files was being archived in the history section
* Fix minor defect in autodeploy and update that would display an error if enter was pressed with a blank entry instead of a response
* Change autodeploy to only copy the necessary files
* Change autodeploy so that the gps file is created in the execution directory
* Change update to copy LICENSE and README.md too
* Add a link back to the GitHub page and a this version history
* Tidy up on sun times page

## v1.1

* Various bug fixes. Details not noted at the time as before versioning was added

## v1.0

* Initial public release 
