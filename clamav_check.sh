#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

#set -x
# Script for detect viruses from FTP
# result is here /tmp/quarantine/ftp_moved_files.log

DATE=$(date +%d-%m-%Y_%H:%M:%S)
HOST=$(hostname -f)
EMAILTO="hosting-security@example.com"

SUBJECT="detected by ClamAV from FTP on"
EMAILMESSAGE="/tmp/quarantine/ftp_mail.log"
OUT="/tmp/quarantine/ftp_out.log"
ALLOG="/tmp/quarantine/ftp_moved_files.log"

# check conditions
#------------------------------------------------------------------------------------------
if [ ! -d /tmp/quarantine ]						# if not equal, not success
then
	mkdir -p /tmp/quarantine > /dev/null 2>&1
	chmod 740 /tmp/quarantine -R > /dev/null 2>&1
	chmod g+s /tmp/quarantine -R > /dev/null 2>&1
fi

# Exclude FTP requests from temporary files
#------------------------------------------------------------------------------------------
echo "$1" | grep -E "\.tmp$" > /dev/null 2>&1				# exclude
if [ 0 -ne $? ]								# if not equal, not success
then

# Scan the uploaded file. Move to quarantine if suspicious
#------------------------------------------------------------------------------------------

	clamdscan -i --move=/tmp/quarantine --fdpass --quiet --no-summary --stdout>$OUT "$1"

	# clamdscan --move=/tmp/quarantine --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"
	# clamdscan --remove --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"

else
	exit 0
fi

CODE="$?"

# send email with viruses
#------------------------------------------------------------------------------------------
if [ 1 -eq "$CODE" ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE

	{
		echo "Foud some viruses during transfer FTP in"
		echo "----------------------------------------------------------"
		cat $OUT
	} >> $EMAILMESSAGE

	cat $EMAILMESSAGE >> $ALLOG
	echo "" >> $ALLOG
#	echo "Please, run for check clamscan -i -r /tmp/quarantine" >> $EMAILMESSAGE
	mail -s "Vriruses $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE
	chmod 000 /tmp/quarantine/* > /dev/null 2>&1

# send email with errors
#------------------------------------------------------------------------------------------
elif [ 2 -eq "$CODE" ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE

	{
		echo "Foud some errors during scanning from ClamAV transfer FTP in"
		echo "----------------------------------------------------------"
		cat $OUT
	} >> $EMAILMESSAGE

	cat $EMAILMESSAGE >> $ALLOG
	echo "" >> $ALLOG
#	mail -s "Errors $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE
fi
