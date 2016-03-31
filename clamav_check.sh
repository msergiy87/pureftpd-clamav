#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

#set -x
# Script for detect viruses from FTP
# result is here /var/log/clamav/ftp-clamdscan.log

DATE=$(date +%d-%m-%Y_%H:%M:%S)
HOST=$(hostname -f)
EMAILTO="hosting-security@example.com"

SUBJECT="detected by ClamAV from FTP on"
EMAILMESSAGE="/tmp/quarantine/ftp_mail.log"
OUT="/tmp/quarantine/ftp_out.log"
ALLOG="/var/log/clamav/ftp-clamdscan.log"
SCAN_FILE="$1"

# check conditions
#------------------------------------------------------------------------------------------
if [ ! -d /tmp/quarantine ]						# if not equal, not success
then
	mkdir -p /tmp/quarantine > /dev/null 2>&1
	chmod 740 /tmp/quarantine -R > /dev/null 2>&1
	chmod g+s /tmp/quarantine -R > /dev/null 2>&1
fi

	if [ ! -f /etc/logrotate.d/ftp-clamdscan ]
	then
		cat > /etc/logrotate.d/ftp-clamdscan <<- _EOF_
		/var/log/clamav/ftp-clamdscan.log {
		     weekly
		     missingok
		     rotate 12
		     compress
		     delaycompress
		     minsize 1048576
		     notifempty
		     create 640 clamav adm
		}
		_EOF_
	fi

# Exclude FTP requests from temporary files
#------------------------------------------------------------------------------------------
echo "$SCAN_FILE" | grep -E "\.tmp$" > /dev/null 2>&1			# exclude
if [ 0 -ne $? ]								# if not equal, not success
then

	# Scan the uploaded file. Move to quarantine if suspicious
	clamdscan -i --move=/tmp/quarantine --fdpass --no-summary --stdout>$OUT "$SCAN_FILE"

	# clamdscan --move=/tmp/quarantine --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"
	# clamdscan --remove --fdpass --quiet --no-summary --log=/var/log/removed_files.log "$1"

else
	echo "Date: $DATE" >> $ALLOG
	echo "Exclude tmp file $SCAN_FILE from scanning" >> $ALLOG
	echo "" >> $ALLOG
	exit 113
fi

CODE="$?"

# no problems
#------------------------------------------------------------------------------------------
if [ 0 -eq "$CODE" ]							# equal
then
	exit 0

# send email with viruses
#------------------------------------------------------------------------------------------
elif [ 1 -eq "$CODE" ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE

	{
		echo "Foud some viruses during scanning $SCAN_FILE in FTP transfer"
		echo "----------------------------------------------------------"
		cat $OUT
	} >> $EMAILMESSAGE

	cat $EMAILMESSAGE >> $ALLOG
	echo "" >> $ALLOG
	mail -s "Vriruses $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE
	chmod 000 /tmp/quarantine/* > /dev/null 2>&1

# send email with errors
#------------------------------------------------------------------------------------------
elif [ 2 -eq "$CODE" ]							# equal 
then
	echo "Date: $DATE" > $EMAILMESSAGE

	{
		echo "Foud some ERRORS during scanning $SCAN_FILE in FTP transfer"
		echo "----------------------------------------------------------"
		cat $OUT
	} >> $EMAILMESSAGE

	cat $EMAILMESSAGE >> $ALLOG
	echo "" >> $ALLOG
#	mail -s "Errors $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE

else
	echo "Date: $DATE" > $EMAILMESSAGE
	{
		echo "Foud some PROBLEMS during scanning $SCAN_FILE in FTP transfer. End code is $CODE"
		echo "----------------------------------------------------------"
		cat $OUT
	} >> $EMAILMESSAGE

	cat $EMAILMESSAGE >> $ALLOG
	echo "" >> $ALLOG
#	mail -s "Problems $SUBJECT $HOST" "$EMAILTO" < $EMAILMESSAGE
fi
