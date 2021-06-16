#!/bin/bash

WEBPATH="/var/www/html"

# Get the remaining space on the memory card/disk and remove enough history to ensure at least 2G remains
arrDf=($(df --output=avail /))
remainingSpace=${arrDf[1]}
echo -e "\nRemaining space:$remainingSpace"

attemptsCount=5
echo "Remaining attempts: $attemptsCount"

# Size seems to be in K (or blocks of 1024), so 2097152 blocks is the equivalent of 2G
while [ $remainingSpace -lt 2097152 ] && [ $attemptsCount -gt 0 ]; do
  # Select the oldest item for removal
  arrDir=($(ls -rt $WEBPATH/history/))

  # Ensure there are directories there that can be removed
  if [ ${#arrDir[@]} -gt 0 ]; then
    # Remove the files from the directory
    echo "Removing:$WEBPATH/history/${arrDir[0]}/"
    sudo rm -rf $WEBPATH/history/${arrDir[0]}/
    # And then remove the directory
    sudo rmdir $WEBPATH/history/${arrDir[0]}/

    # Decrement the remaining attempts
    attemptsCount=$(( $attemptsCount - 1 ))

    arrDf=($(df --output=avail /))
    remainingSpace=${arrDf[1]}
    echo "Remaining space is now:'$remainingSpace'"
    echo "Remaining attempts (if not completed): $attemptsCount"
  else
    echo "No directories to remove"
    attemptsCount=0
  fi
done

df -h
