# pureftpd-clamav
This is script that you should use with PureFTPd and ClamAV for virus scanning on a fly.

For configuration pure-ftpd i use this tutorial 

Requirements
------------


Usage
------------

https://www.howtoforge.com/how-to-integrate-clamav-into-pureftpd-for-virus-scanning-on-debian-squeeze

Install ClamAV
```
apt-get install clamav clamav-daemon clamav-docs clamav-freshclam
```
Install PureFTPd
```
apt-get install pure-ftpd-common pure-ftpd-mysql
```
Configure PureFTPd
```
vim /etc/default/pure-ftpd-common

STANDALONE_OR_INETD=standalone
VIRTUALCHROOT=true
UPLOADSCRIPT=/root/scripts/clamav_check.sh

echo "yes" > /etc/pure-ftpd/conf/CallUploadScript

/etc/init.d/pure-ftpd-mysql restart
```
Just copy script and set rights.
```
chmod 755 /root/scripts/clamav_check.sh
```
