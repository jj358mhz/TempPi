#!/bin/bash

set -x

#  This script reads the Broadcom SoC temperature value and shuts down if it
#  exceeds a particular value.
#  80ºC is the maximum allowed for a Raspberry Pi.

# Copyright (C) 2014-2019 Jeff Johnston <jj358mhz@gmail.com>

# This script work with a secondary script called ( post_to_slack )

# File Locations for Raspberry Pi (Debian based)
### /usr/local/bin/tempcheck.sh      ( this file )
### /usr/local/bin/post_to_slack     ( post_to_slack )

# Schedule a cronjob to run every 5 minutes
# sudo crontab -e and paste the entry below
# */5 * * * *    /usr/local/bin/tempcheck.sh >/dev/null 2>&1

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

##################################################################

# Enter your Slack webhook
SLACK_WEBHOOK=
#Enter you Slack channel name
SLACK_CHANNEL="YOUR_SLACK_CHANNEL_NAME_HERE"
# Enter the title of your device
TITLE="UC Berkeley Police"
# Slack emoji (you can change to suit your needs)
EMOJI=fire

# Path to Slack Script ***Enter Yours Below***
POST_TO_SLACK="/usr/local/bin/post_to_slack"

# Get the reading from the sensor and strip the non-number parts
SENSOR="`/opt/vc/bin/vcgencmd measure_temp | cut -d "=" -f2 | cut -d "'" -f1`"
# -gt only deals with whole numbers, so round it.
TEMP="`/usr/bin/printf "%.0f\n" ${SENSOR}`"
# 80ºC is the maximum allowed for a Raspberry Pi.
# How hot will we allow the SoC to get in Celsius?
MAX="60"

if [ "${TEMP}" -gt "${MAX}" ] ; then
 # This will be mailed to root if called from cron
 echo "${TEMP}ºC is too hot!"
 # Send a message to Slack
 $POST_TO_SLACK -t "${TITLE} Alert" -e "${EMOJI}" -b "${TEMP}ºC is too hot!" -c "${SLACK_CHANNEL}" -u "$SLACK_WEBHOOK"
 # Send a message to syslog
 /usr/bin/logger "Shutting down due to SoC temp ${TEMP}."
 # Halt the box (UNCOMMENT LINE BELOW AFTER YOU TEST)
 #/sbin/shutdown -h now
 else
  exit 0
fi
