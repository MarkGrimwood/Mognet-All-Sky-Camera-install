# All Sky Camera code for the Raspberry Pi

This project was created as a minimum viable product for all sky camera software that would handle backend capture automatically and provide a front end to display the image along with videos and saved image history while also being lightweight enough to run on a Raspberry Pi Zero W without stress. It is based on a previous all sky camera by Pete https://github.com/rederikus/AllSky-Camera-Raspberry-Pi and also contains the SunWait executable from https://github.com/risacher/sunwait

The code sets up a cron job to capture an image once per minute during the day, or every two minutes at night. Each image is date and timestamped, and appended to an Mpeg for the relevant period. The saved periods are archived until the memory card is almost full, at which point the oldest period is deleted. At noon every day the crontab file is regenerated for the changing sunrise and sunset times. 

Using an RPi Zero has the advantage of being low cost, meaning that if it gets stolen or suffers a weather related failure, then financial loss is minimised

# Parts

* A Raspberry Pi Zero WH (or W) like this: https://thepihut.com/collections/raspberry-pi/products/raspberry-pi-zero-wh-with-pre-soldered-header
* A Raspberry Pi V2 camera module. It doesn't matter if it has the IR filter or not https://thepihut.com/collections/raspberry-pi-camera/products/raspberry-pi-noir-camera-module
* A suitable wide angle lens e.g. https://thepihut.com/collections/raspberry-pi-camera-lenses/products/m12-lens-180-degree-fisheye-1-2-5-optical-format-1-7mm-focal-length
* A power supply for the Pi
* A memory card. This needs to be a fast transfer one suitable for video or CCTV capture and ideally 16 or 32Gb in size. My 64Gb card currently holds seven weeks worth of captures!

A CCTV type dome if fitting outside. They can also be used from indoors, but double glazing and household lighting can cause internal reflections. There are plenty of examples for building external camera enclosures already, so I won't add to them

A 3D printer is useful for creating all the fittings

# Before installation

You will need to know your latitude and longitude. An approximate location is fine as this information is only used for timings of sunrise, sunset etc. The values are entered separately in decimal format with the N/S and E/W indicators. Those values will be truncated to two decimal points, so a precise location of 52.202175N, 0.128179E will become 52.20N and 0.12E

# Installation

Initialise the memory card with a version of Raspbian. For the RPi Zero Raspbian Lite is probably the best version to go for
Set up on the card for wifi and ssh
Then assemble the RPi, camera and power supply, insert the card and turn it on. Give it a couple minutes to sort itself out

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

You will be prompted for your latitude and longitude, and then after that everything should automatic. The auto deploy script will also make sure that the updates are done to the RPi. Once complete (approx 10-15 minutes on a RPi Zero) the installer script will give the URL for viewing the captured images, etc and viewing is just through a normal web browser 

# Oddities

Occasionally odd things happen. I've seen half images sometimes which I haven't identified the cause of yet. They only occur in the live view and don't appear on the video or image history. And there are sometimes issues with displaying the videos where they are slow to download or a new version of the video gets copied over the existing one while a download is in progress and things get tangled. My background is mainframe assembler and Cobol and then automated testing. I'm still new to web design and coding so haven't delved into the intricacies of it yet.

# The future

There are a few bits that need to be sorted
* Daily regeneration script to include RPi security update and bug fix check. I did have code there but seem to have lost it in one of the forced rebuilds.
* Air temperature sensor code. Pete's original version had that as an option and I didn't get round to buying the necessary sensor, so I disabled the code for now. 
* Revisit the timing setup script. I don't know how well it will work for locations close to the polar circles towards midsummer and midwinter, and for inside the polar circles at those times I haven't written anything yet. I think there may be a better way to do it than what I've done for this version
* Updater script. So that when there's an update it just overwrite the script parts and preserve the history.
* Refactoring common code. There are two pairs of scripts (captureday.sh/capturenight.sh and newdaymovie.sh/newnightmovie.sh) that share common code. These should really be amalgamated and parameterised to make maintenance easier.
