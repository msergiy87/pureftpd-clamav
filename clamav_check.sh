#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

#set -x
# Script for detect viruses from FTP
# result is here /var/log/removed_files.log

DATE=`date`
HOST=`hostname -f`
EMAILTO="hosting-security@example.com"

SUBJECT="detected by ClamAV from FTP on"
EMAILMESSAGE="/tmp/quarantine/mail.log"
OUT="/tmp/quarantine/out.log"
ALLOG="/var/log/removed_files.log"

# check conditions
#------------------------------------------------------------------------------------------
ls /tmp/quarantine > /dev/null 2>&1
if [ $? -ne 0 ]								# if not equal, not success
then
	mkdir -p /tmp/quarantine > /dev/null 2>&1
	chmod 740 /tmp/quarantine -R > /dev/null 2>&1
	chmod g+s /tmp/quarantine -R > /dev/null 2>&1
fi

# Exclude FTP requests from temporary files
#------------------------------------------------------------------------------------------
echo "$1" | grep -E "\.tmp" > /dev/null 2>&1				# exclude
if [ $? -ne 0 ]								# if not equal, not success
then

# Scan the uploaded file. Move to quarantine if suspicious
#------------------------------------------------------------------------------------------

	/usr/bin/clamdscan -i --move=/tmp/quarantine --fdpass --no-summary --stdout>$OUT --log=$ALLOG "$1"

	#/usr/bin/clamdscan --move=/tmp/quarantine --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"
	#/usr/bin/clamdscan --remove --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"

else exit 0
fi

CODE=`echo "$?"`

# send email with viruses
#------------------------------------------------------------------------------------------
if [ $CODE -eq 1 ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE
	echo "Foud some viruses during transfer FTP in" >> $EMAILMESSAGE
	cat "$OUT" >> $EMAILMESSAGE
	echo "" >> $EMAILMESSAGE
#	echo "Please, run for check /usr/bin/clamscan -i -r /tmp/quarantine" >> $EMAILMESSAGE
	/usr/bin/mail -s "Vriruses $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE
	/bin/chmod 000 /tmp/quarantine/* > /dev/null 2>&1

# send email with errors
#------------------------------------------------------------------------------------------
elif [ $CODE -eq 2 ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE
	echo "Foud some errors during scanning from ClamAV transfer FTP in" >> $EMAILMESSAGE
	cat "$OUT" >> $EMAILMESSAGE
#	/usr/bin/mail -s "Errors $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE

else exit 0
fi
