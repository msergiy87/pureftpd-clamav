# pureftpd-clamav
This is script that you should use with PureFTPd and ClamAV for virus scanning on a fly.

For configuration pure-ftpd I used this tutorial https://www.howtoforge.com/how-to-integrate-clamav-into-pureftpd-for-virus-scanning-on-debian-squeeze

Requirements
------------


Install ClamAV
```
apt-get install clamav clamav-daemon clamav-docs clamav-freshclam
```
Install PureFTPd
```
apt-get install pure-ftpd-common pure-ftpd-mysql
```

Distros tested
------------

Currently, this is only tested on Debian 7.9. It should theoretically work on older versions of Ubuntu or Debian based systems.

ClamAV 0.99

PureFTPd 1.0.36

Usage
------------

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


ISP-Config: Deploy hosting control panel

Goal:

1) Deploy hosting control panel and transfer sites from old hosting.

2) Protect sites using antivirus programs. 

3) Configuring Linux disk quotas to limit user disk resources. 

4) Configure iptables.

5) Rotate log files.

6) Create statistics.  

Deployed hosting control panel, that consist of:

1) Master server - with web interface of panel for management

2) Slave servers - with sites (50 per server), webserver, mysql bases, ftp users. 

Result:

1) Transferred 50 sites to the ISP-Config.

2) Wrote scripts to automate administrative tasks of hosting control.

3) Protect servers from attacks.

![ispc](https://github.com/msergiy87/pureftpd-clamav/blob/master/ispc.jpg)
