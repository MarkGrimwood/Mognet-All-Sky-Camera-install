#!/bin/bash

# ****************************************************************************************************************************
#
# This is the main setup script for the all sky camera. It generates all the crontab items to trigger captures, etc
#
# ****************************************************************************************************************************

HOME="/home/pi/Mognet-All-Sky-Camera/back-end"	# Working directory
WEB="/var/www/html"
NEWDAYMOVIE="newmovie.sh day"
NEWNIGHTMOVIE="newmovie.sh night"
CAPTUREDAY="capture.sh day"
CAPTURENIGHT="capture.sh night"

# Interval for raspistill to take shots.  Night time needs to be longer since raspistill needs longer at night to complete as
# it can take raspistill up to 1 minute 15 seconds to process a ten second night time image
shotD=1 # Daytime shot interval
shotN=2 # Night time shot interval

# *** S E T U P **********************************************************************

THISSCRIPT=${0}

# Get the latitude and longitude from the gps file. Values were set in the autodeploy
arrGPS=($(cat gps))
lat=${arrGPS[0]}
lon=${arrGPS[1]}

# Offsets advance or retard the Day or Twilight times in sunwait.  Anything in between is night
# Offsets.  May be + or - Positive numbers move twilight or sunrise/sunset closer to noon.
# Negative numbers move them away from noon. This adjusts when the camera changes from
# Twilight, Day and Night modes allowing a smoother transition of images from light to
# dark and vice versa.
# The camera offset allows the Day / Night exposure settings of the camera to be indempendent
# from Video Day / Night changover.  This helps to prevent spashes of light (or dark) at the
# beginning and end of videos>
#
# Shifts camera mode time at  Morning Twilight / Day
#       HH:MM
twiRise=-00:10 # Advance or delay the displayed time.
twiRiseP=-00:08 # Camera switch time.  Needs to be at least 1 minute EARLIER than the Video switch time.
twiRiseVid=-00:03 # Offset advance or delay for the Video Day / Night switch.

# Shifts camera mode time at Morning Twilight /  Day
#     HH:MM Not used anymore
SRise=00:00 # Advance or delay when the camera switches from night to day.
SRiseP=00:00 # Camera switch time. Needs to be at least 1 minute EARLIER than the Video switch time.
SRiseVid=00:00 # Offset advance or delay for the Video Day / Night switch.

# Shifts camera mode time at Day / Evening Twilight
# For the dusk  camera mode
#     HH:MM Not used anymore
SSet=-00:00 # Advance or delay when the camera switches from night to day.
SSetP=00:00 # Camera switch time.  Needs to be at least 1 minute EARLIER than the Video switch time.
SSetVid=-00:00 # Offset advance or delay for the Video Day / Night switch.

# Shifts camera mode time at Evening Twilight / NIght
# For the night camera mode
#       HH:MM
twiSet=-00:00 # Advance or delay when the camera switches from day to night.
twiSetP=-00:09 # Camera switch time.  Needs to be at least 1 minute EARLIER than the Video switch time.
twiSetVid=-00:12 # Offset advance or delay for the Video Day / Night switch.

# *** E N D   O F   S E T U P *************************************************************************

# Sunwait to get today's times
# Sunrise and set. 0 degrees below horizon
SunRise=$(sunwait list 1 sun rise offset $SRise $lon $lat)
SunRiseReal=$(sunwait list 1 sun rise $lon $lat)
SunSetReal=$(sunwait list 1 sun set $lon $lat)
SunRiseCam=$(sunwait list 1 sun rise offset $SRiseP $lon $lat)
SunSetCam=$(sunwait list 1 sun set offset $SSetP $lon $lat)
SunSet=$(sunwait list 1 sun set offset $SSet $lon $lat)
SunPollRise=$(sunwait poll sun rise offset $SRise $lon $lat)
SunPollSet=$(sunwait poll sun set offset $SSet $lon $lat)
SunRiseVid=$(sunwait list 1 sun rise offset $SRiseVid $lon $lat)
SunSetVid=$(sunwait list 1 sun set offset $SSetVid $lon $lat)

# Astronomical dawn and set. 18 degrees below horizon
AstroRise=$(sunwait list 1 astronomical rise offset $twiRise $lon $lat)
AstroRiseReal=$(sunwait list 1 astronomical rise $lon $lat)
AstroSetReal=$(sunwait list 1 astronomical set $lon $lat)
AstroSet=$(sunwait list 1 astronomical set offset $twiSet $lon $lat)
AstroRiseCam=$(sunwait list 1 astronomical rise offset $twiRiseP $lon $lat)
AstroSetx=$(sunwait list 1 astronomical set offset $twiSetP $lon $lat)
AstroPollRisCam=$(sunwait poll astronomical rise offset $twiRise $lon $lat)
AstroPollSet=$(sunwait poll astronomical set offset $twiSet $lon $lat)
AstroRiseVid=$(sunwait list 1 astronomical rise offset $twiRiseVid $lon $lat)
AstroSetVid=$(sunwait list 1 astronomical set offset $twiSetVid $lon $lat)

# Nautical dawn and set. 12 degrees below horizon
NauticalRise=$(sunwait list 1 nautical rise offset $twiRise $lon $lat)
NauticalRiseReal=$(sunwait list 1 nautical rise $lon $lat)
NauticalSetReal=$(sunwait list 1 nautical set  $lon $lat)
NauticalSet=$(sunwait list 1 nautical set offset $twiSet $lon $lat)
NauticalRiseCam=$(sunwait list 1 nautical rise offset $twiRiseP $lon $lat)
NauticalSetCam=$(sunwait list 1 nautical set offset $twiSetP $lon $lat)
NauticalPollRise=$(sunwait poll nautical rise offset $twiRise $lon $lat)
NauticalPollSet=$(sunwait poll nautical set offset $twiSet $lon $lat)
NauticalRiseVid=$(sunwait list 1 nautical rise offset $twiRiseVid $lon $lat)
NauticalSetVid=$(sunwait list 1 nautical set offset $twiSetVid $lon $lat)

# Civil dawn and set. 6 degrees below horizon
CivilRise=$(sunwait list 1 civil rise offset $twiRise $lon $lat)
CivilRiseReal=$(sunwait list 1 civil rise $lon $lat)
CivilSetReal=$(sunwait list 1 civil set $lon $lat)
CivilSet=$(sunwait list 1 civil set offset $twiSet $lon $lat)
CivilRiseCam=$(sunwait list 1 civil rise offset $twiRiseP $lon $lat)
CivilSetCam=$(sunwait list 1 civil set offset $twiSetP $lon $lat)
CivilPollRise=$(sunwait poll civil rise offset $twiRise $lon $lat)
CivilPollSet=$(sunwait poll civil set offset $twiSet $lon $lat)
CivilRiseVid=$(sunwait list 1 civil rise offset $twiRiseVid $lon $lat)
CivilSetVid=$(sunwait list 1 civil set offset $twiSetVid $lon $lat)
# **************************************************************

# Selects the Dawn / Twilight parameter (civil, nautical or astronomical) for cron and for raspistill arguments
# Can be civil, nautical or astronomical.  All four, Rise, Set, Poll and x must be set.
# This also defines the switch times between Day and Night Videos and the camera.
CameraAM=$CivilRiseCam
CameraPM=$CivilSetCam

twilightRiseCam=$CameraAM
twilightSetCam=$CameraPM

twilightSetVid=$CivilSetVid
twilightRiseVid=$CivilRiseVid

twilightRise=$CivilRise
twilightSet=$CivilSet

twilightPollRise=$CivilPollRise
twilightPollSet=$CivilPollSet

# Get the hours and minutes separated for the four times we are using.
# On time
#dawntwi=${twilightRise:0:5}; srise=${SunRise:0:5}; sset=${SunSet:0:5}; evetwi=${twilightSet:0:5}
# As above but hatever the "x" time advance or delay is set to.  This is to ensure that the sunwait poll time is past before webcam is run.
# This makes sure that we always get a definite trabsition condition because cron runs jobs to the second and whilst sunwait
# rounds times to  HH:MM actual suntimes do involve seconds.
dawntwi=${twilightRiseCam:0:5}; srise=${SunRise:0:5}; sset=${SunSet:0:5}; evetwi=${twilightSetCam:0:5}
dawntwiVid=${twilightRiseVid:0:5}; sRiseVid=${SunRiseVid:0:5}; sSetVid=${SunSetVid:0:5}; evetwiVid=${twilightSetVid:0:5}

# Chop up Hours and Minutes to get seperate variables.  Get rid of the " : "
amtH=${dawntwi:0:2}; amtM=${dawntwi:3:2} # Dawn
amtHVid=${dawntwiVid:0:2}; amtMVid=${dawntwiVid:3:2}
dayH=${srise:0:2}; dayM=${srise:3:2} # Day
dayHVid=${sRiseVid:0:2}; dayMVid=${sRiseVid:3:2}
twiH=${sset:0:2}; twiM=${sset:3:2} # Twilight
twiHVid=${sSetVid:0:2}; twiMVid=${sSetVid:3:2}
nigH=${evetwi:0:2}; nigM=${evetwi:3:2} # Night
nigHVid=${evetwiVid:0:2}; nigMVid=${evetwiVid:3:2}

# Write the sun times to the daily file for use by the web pages.
echo -e $AstroRiseReal"\n"$NauticalRiseReal"\n"$CivilRiseReal"\n"$SunRiseReal"\n"$SunSetReal"\n"$CivilSetReal"\n"$NauticalSetReal"\n"$AstroSetReal>$HOME/daily
# Write the shot times to the daily file
echo -e $twilightRiseVid"\n"$twilightSetVid"\n"$CameraAM"\n"$CameraPM>>$HOME/daily

sudo cp $HOME/gps "$WEB/"
sudo chown nobody "$WEB/gps"
sudo cp $HOME/daily "$WEB/"
sudo chown nobody "$WEB/daily"

# Write the crontab file
echo "#* * * * *">$HOME/mgasccron
echo "#* * * * *">>$HOME/mgasccron
echo "#* * * * *">>$HOME/mgasccron
echo "#* * * * *">>$HOME/mgasccron
echo "#0123456789 command to be executed - - - - -">>$HOME/mgasccron
echo "# m h dom mon dow command">>$HOME/mgasccron
echo "# * *  *   *   *">>$HOME/mgasccron
echo "# | |  |  / __/">>$HOME/mgasccron
echo "# | |  / / /">>$HOME/mgasccron
echo "# * * * * *">>$HOME/mgasccron
echo "# . . . . .">>$HOME/mgasccron
echo "# . . . . ----- Day of week (0 - 7) (Sunday=0 or 7)">>$HOME/mgasccron
echo "# . . . ------- Month (1 - 12)">>$HOME/mgasccron
echo "# . . --------- Day of month (1 - 31)">>$HOME/mgasccron
echo "# . ----------- Hour (0 - 23)">>$HOME/mgasccron
echo "# ------------- Minute (0 - 59)">>$HOME/mgasccron
echo "# * * * * *">>$HOME/mgasccron
echo "# *************************************">>$HOME/mgasccron
echo "#">>$HOME/mgasccron


# Daily regeneration at noon
echo "# Regeneration">>$HOME/mgasccron
echo "0 12 * * * $HOME/dailyupdate.sh">>$HOME/mgasccron
echo "">>$HOME/mgasccron

# Flag if we're dealing with polar day or night
polar="NO"
if [ $(echo $SunRiseCam | grep "Polar night" | wc -l) -ne 0 ]; then
  polar="NIGHT"
fi
if [ $(echo $SunRiseCam | grep "Midnight sun" | wc -l) -ne 0 ]; then
  polar="DAY"
fi

# Fix the values if we have an all day or all night situation
if [ ${SunRiseVid:0:5} == "--:--" ]; then
  SunRiseVid="00:00"
fi
if [ ${SunSetVid:0:5} == "--:--" ]; then
  SunSetVid="00:00"
fi

# Sort out hour and minute of the start of the day
dayStartH=${twilightRiseVid:0:2}
dayStartM=${twilightRiseVid: -2}

# Sort out hour and minute of the end of the day
dayEndH=${twilightSetVid:0:2}
dayEndM=${twilightSetVid: -2}

# Sort out hour and minute of the start of the night
nightStartH=${twilightSetVid:0:2}
nightStartM=${twilightSetVid: -2}

# Sort out hour and minute of the end of the night
nightEndH=${twilightRiseVid:0:2}
nightEndM=${twilightRiseVid: -2}

# And because bash handles numbers in an odd way
if [ ${dayStartH:0:1} -eq "0" ]; then
  dayStartH=${dayStartH:1}
fi
if [ ${dayStartM:0:1} -eq "0" ]; then
  dayStartM=${dayStartM:1}
fi
if [ ${dayEndH:0:1} -eq "0" ]; then
  dayEndH=${dayEndH:1}
fi
if [ ${dayEndM:0:1} -eq "0" ]; then
  dayEndM=${dayEndM:1}
fi
if [ ${nightStartH:0:1} -eq "0" ]; then
  nightStartH=${nightStartH:1}
fi
if [ ${nightStartM:0:1} -eq "0" ]; then
  nightStartM=${nightStartM:1}
fi
if [ ${nightEndH:0:1} -eq "0" ]; then
  nightEndH=${nightEndH:1}
fi
if [ ${nightEndM:0:1} -eq "0" ]; then
  nightEndM=${nightEndM:1}
fi

echo "$dayStartM $dayStartH * * * $HOME/pics/$NEWDAYMOVIE">>"$HOME/mgasccron"
echo "$nightStartM $nightStartH * * * $HOME/pics/$NEWNIGHTMOVIE">>"$HOME/mgasccron"

# Adjust timings for shots - first the generic functions
function adjustHourUp() {
  h=$1
  m=$2
  o=$3
  r=$(( $m + $o ))
  if [ $r -ge 60 ]; then
    h=$(( $h + 1 ))
  fi
  if [ $h -ge 24 ]; then
    h=$(( $h - 24 ))
  fi
  return $h
}

function adjustMinutesUp() {
  m=$1
  o=$2
  r=$(( $m + $o ))
  if [ $r -ge 60 ]; then
    r=$(( $r - 60 ))
  fi
  return $r
}

function adjustHourDown() {
  h=$1
  m=$2
  o=$3
  r=$(( $m - $o ))
  if [ $r -lt 0 ]; then
    h=$(( $h - 1 ))
  fi
  if [ $h -lt 0 ]; then
    h=$(( $h + 24 ))
  fi
  return $h
}

function adjustMinutesDown() {
  m=$1
  o=$2
  r=$(( $m - $o ))
  if [ $r -lt 0 ]; then
    r=$(( $r + 60 ))
  fi
  return $r
}

# Adjust times for shots - the reassignments
adjustHourUp $dayStartH $dayStartM $shotD
dayStartH=$?
adjustMinutesUp $dayStartM $shotD
dayStartM=$?

adjustHourDown $dayEndH $dayEndM $shotD
dayEndH=$?
adjustMinutesDown $dayEndM $shotD
dayEndM=$?

adjustHourUp $nightStartH $nightStartM $shotN
nightStartH=$?
adjustMinutesUp $nightStartM $shotN
nightStartM=$?

adjustHourDown $nightEndH $nightEndM $shotN
nightEndH=$?
adjustMinutesDown $nightEndM $shotN
nightEndM=$?

# Standard rules applied, where the day starts before the end in clock time
function standardRules() {
  nsPeriodStartH=${1}	#dayStartH
  nsPeriodStartM=${2}	#dayStartM
  nsPeriodEndH=${3}	#dayEndH
  nsPeriodEndM=${4}	#dayEndM
  nsShotP=${5}		#shotD
  nsCommand=${6}	#day or night
  sPeriodStartH=${7}	#nightStartH
  sPeriodStartM=${8}	#nightStartM
  sPeriodEndH=${9}	#nightEndH
  sPeriodEndM=${10}	#nightEndM
  sShotP=${11}		#shotN
  sCommand=${12}	#night or day

  # Is the day just a part of an hour?
  if [ $nsPeriodStartH -eq $nsPeriodEndH ]; then
    echo -e "\n# Just part of an hour">>"$HOME/mgasccron"
    for ((loop=$nsPeriodStartM; loop<=$nsPeriodEndM; loop=loop+nsShotP)); do
      echo "$loop $nsPeriodStartH * * * $nsCommand">>"$HOME/mgasccron"
    done
  else
    # Is the start of the day capture just part of an hour?
    if [ $nsPeriodStartM -ne 0 ]; then
      # It's just part of an hour
      echo -e "\n# Fill part of an hour before">>"$HOME/mgasccron"
      for ((loop=$nsPeriodStartM; loop<60; loop=loop+nsShotP)); do
        echo "$loop $nsPeriodStartH * * * $nsCommand">>"$HOME/mgasccron"
      done
      nsPeriodStartH=$(( $nsPeriodStartH + 1 ))
    fi

    # Is the end of the day capture just part of an hour?
    if [ $nsPeriodEndM -lt $(( 60-nsShotP )) ]; then
      echo -e "\n# Fill part of an hour after">>"$HOME/mgasccron"
      for ((loop=0; loop<=$nsPeriodEndM; loop=loop+nsShotP)); do
        echo "$loop $nsPeriodEndH * * * $nsCommand">>"$HOME/mgasccron"
      done
      nsPeriodEndH=$(( $nsPeriodEndH - 1 ))
    fi

    # Are there intervening hour(s) to fill for day capture?
    if [ $nsPeriodStartH -eq $nsPeriodEndH ]; then
      echo -e "\n# Intervening hour">>"$HOME/mgasccron"
      echo "*/$nsShotP $nsPeriodStartH * * * $nsCommand">>"$HOME/mgasccron"
    elif [ $nsPeriodStartH -lt $nsPeriodEndH ]; then
      echo -e "\n# Intervening hours">>"$HOME/mgasccron"
      echo "*/$nsShotP $nsPeriodStartH-$nsPeriodEndH * * * $nsCommand">>"$HOME/mgasccron"
    fi
  fi

  # Is the start of the night capture just part of an hour?
  if [ $sPeriodStartM -ne 0 ]; then
    # It's just part of an hour
    echo -e "\n# Fill part of an hour before (split period)">>"$HOME/mgasccron"
    for ((loop=$sPeriodStartM; loop<60; loop=loop+sShotP)); do
      echo "$loop $sPeriodStartH * * * $sCommand">>"$HOME/mgasccron"
    done
    sPeriodStartH=$(( $sPeriodStartH + 1 ))
  fi

  # Is the end of the night capture just part of an hour?
  if [ $sPeriodEndM -lt $(( 60-sShotP )) ]; then
    echo -e "\n# Fill part of an hour after (split period)">>"$HOME/mgasccron"
    for ((loop=0; loop<=$sPeriodEndM; loop=loop+sShotP)); do
      echo "$loop $sPeriodEndH * * * $sCommand">>"$HOME/mgasccron"
    done
    sPeriodEndH=$(( $sPeriodEndH - 1 ))
  fi

  # Are there intervening hours to fill for night capture before midnight?
  if [ $sPeriodStartH -eq 23 ]; then
    echo -e "\n# Intervening hour before midnight (split period)">>"$HOME/mgasccron"
    echo "*/$sShotP 23 * * * $sCommand">>$HOME/mgasccron
  elif [ $sPeriodStartH -lt 24 ]; then
    echo -e "\n# Intervening hours before midnight (split period)">>"$HOME/mgasccron"
    echo "*/$sShotP $sPeriodStartH-23 * * * $sCommand">>"$HOME/mgasccron"
  fi

  # Are there intervening hours to fill for night capture after midnight?
  if [ $sPeriodEndH -eq 0 ]; then
    echo -e "\n# Intervening hour after midnight (split period)">>"$HOME/mgasccron"
    echo "*/$sShotP 0 * * * $sCommand">>"$HOME/mgasccron"
  elif [ $sPeriodEndH -ge 0 ]; then
    echo -e "\n# Intervening hours after midnight (split period)">>"$HOME/mgasccron"
    echo "*/$sShotP 0-$sPeriodEndH * * * $sCommand">>"$HOME/mgasccron"
  fi
}

# Now to start handling all the situations
if [ $polar != "NO" ]; then
  # We're in a 24 hour day or night situation if we're here
  echo "# Code not yet written - polar day/night">>"$HOME/mgasccron"
else
  # Is our day standard or non-standard?
  if [ "$dayStartH" -lt "$dayEndH" ]; then
    # If the day start is definitely before the day end
    standardRules $dayStartH $dayStartM $dayEndH $dayEndM $shotD "$HOME/pics/$CAPTUREDAY" $nightStartH $nightStartM $nightEndH $nightEndM $shotN "$HOME/pics/$CAPTURENIGHT"
  elif [ "$dayStartH" -eq "$dayEndH" ] && [ "$dayStartM" -lt "$dayEndM" ]; then
    # If the hour is the same but the day start minutes are before the day end (a very short day!)
    standardRules $dayStartH $dayStartM $dayEndH $dayEndM $shotD "$HOME/pics/$CAPTUREDAY" $nightStartH $nightStartM $nightEndH $nightEndM $shotN "$HOME/pics/$CAPTURENIGHT"
  else
    # The non-standard rules are actually the standard rules applied the opposite way round
    standardRules $nightStartH $nightStartM $nightEndH $nightEndM $shotN "$HOME/pics/$CAPTURENIGHT" $dayStartH $dayStartM $dayEndH $dayEndM $shotD "$HOME/pics/$CAPTUREDAY"
  fi
fi


## Display today's Sun rise and set times and the times when the camera switches modes and when the Day / Night video switching happens.
# Write the same data to $HOME/daily_times.txt
echo " ">$HOME/daily_times.txt
echo "E V E N T                                      HH:MM OFFSET">>$HOME/daily_times.txt
echo "---------------------------------------------  ----- ------">>$HOME/daily_times.txt
echo "Astronomical Rise (18 degrees below horizon):  $AstroRise $twiRise">>$HOME/daily_times.txt
echo "Astronomical Rise (Real)                    :  $AstroRiseReal">>$HOME/daily_times.txt
echo "Nautical Rise (12 degrees below horizon)    :  $NauticalRise $twiRise">>$HOME/daily_times.txt
echo "Nautical Rise (Real)                        :  $NauticalRiseReal">>$HOME/daily_times.txt
echo "Civil Rise (6 degrees below horizon)        :  $CivilRise $twiRise">>$HOME/daily_times.txt
echo "Civil Rise (Real)                           :  $CivilRiseReal">>$HOME/daily_times.txt
echo "CAMERA switches from Night to Day           :  $twilightRiseCam $twiRiseP">>$HOME/daily_times.txt
echo "VIDEO switches from Night to Day            :  $twilightRiseVid $twiRiseVid">>$HOME/daily_times.txt
echo "Sunrise (0 degrees below horizon)           :  $SunRise $SRiseP">>$HOME/daily_times.txt
echo "Sunrise (Real)                              :  $SunRiseReal">>$HOME/daily_times.txt
echo "Sunset (0 degrees below horizon)            :  $SunSet $SSetP">>$HOME/daily_times.txt
echo "Sunset (Real)                               :  $SunSetReal">>$HOME/daily_times.txt
echo "Civil Set (6 degrees below horizon)         :  $CivilSet $twiSet">>$HOME/daily_times.txt
echo "Civil Set (Real)                            :  $CivilSetReal">>$HOME/daily_times.txt
echo "CAMERA switches from Day to Night           :  $CameraPM $twiSetP">>$HOME/daily_times.txt
echo "VIDEO switches from Day to Night            :  $twilightSetVid $twiSetVid">>$HOME/daily_times.txt
echo "Nautical Set (12 degrees below horizon)     :  $NauticalSet $twiSet">>$HOME/daily_times.txt
echo "Nautical Set (Real)                         :  $NauticalSetReal">>$HOME/daily_times.txt
echo "Astronomical Set (18 degrees below horizon) :  $AstroSet $twiSet">>$HOME/daily_times.txt
echo "Astronomical Set (Real)                     :  $AstroSetReal">>$HOME/daily_times.txt
echo " ">>$HOME/daily_times.txt
echo "$(date)">>$HOME/daily_times.txt

# Copy to console
cat "$HOME/daily_times.txt"

# *******************************************************************************
# This where the new cron file (mgasccron) gets sent to do its work.
sudo service cron stop   # Stop the cron job
sudo crontab -r          # Remove the current crontab file
sudo crontab "$HOME/mgasccron"
sudo service cron start  # Start the cron job, which will pick up the changes
# ** E N D ***********************************************************************
