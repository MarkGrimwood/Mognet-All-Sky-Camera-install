# All Sky Camera code for the Raspberry Pi

This project was created as a minimum viable product for all sky camera software that would handle backend capture automatically and provide a front end to display the image along with videos and saved image history while also being lightweight enough to run on a Raspberry Pi Zero W without stress. It is based on a previous all sky camera by Pete https://github.com/rederikus/AllSky-Camera-Raspberry-Pi and also contains the SunWait executable from https://github.com/risacher/sunwait

The code sets up a cron job to capture an image once per minute during the day, or every two minutes at night. Each image is date and timestamped, and appended to an Mpeg for the relevant period. The saved periods are archived until the memory card is almost full, at which point the oldest period is deleted. At noon every day the crontab file is regenerated for the changing sunrise and sunset times. 

Using an RPi Zero has the advantage of being low cost, meaning that if it gets stolen or suffers a weather related failure, then financial loss is minimised

Full documentation is available in the Wiki https://github.com/MarkGrimwood/Mognet-All-Sky-Camera-install/wiki And I've started a discussion thread here https://stargazerslounge.com/topic/376932-another-all-sky-camera/

# Quick Setup Guide

## Parts

* A Raspberry Pi Zero WH (or W) like this: https://thepihut.com/collections/raspberry-pi/products/raspberry-pi-zero-wh-with-pre-soldered-header
* A Raspberry Pi V2 camera module. It doesn't matter if it has the IR filter or not https://thepihut.com/collections/raspberry-pi-camera/products/raspberry-pi-noir-camera-module
* A suitable wide angle lens e.g. https://thepihut.com/collections/raspberry-pi-camera-lenses/products/m12-lens-180-degree-fisheye-1-2-5-optical-format-1-7mm-focal-length
* A power supply for the Pi
* A memory card. This needs to be a fast transfer one suitable for video or CCTV capture and ideally 16 or 32Gb in size. My 64Gb card currently holds seven weeks worth of captures!

A CCTV type dome if fitting outside. They can also be used from indoors, but double glazing and household lighting can cause internal reflections. There are plenty of examples for building external camera enclosures already, so I won't add to them

## Before installation

You will need to know your latitude and longitude. An approximate location is fine as this information is only used for timings of sunrise, sunset etc. The values are entered separately in decimal format with the N/S and E/W indicators. Those values will be truncated to two decimal points, so a precise location of 52.202175N, 0.128179E will become 52.20N and 0.12E

## Installation

Initialise the memory card with a version of Raspbian. For the RPi Zero Raspbian Lite is probably the best version to go for
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
