#!/bin/bash
mkdir -p /local/home /local/srv 

#Creates the places where we will bind original files to:
mkdir -p /ro/var /ro/srv /ro/home

cp /etc/adjtime /var/local/adjtime
rm /etc/adjtime; ln -s /var/local/adjtime /etc/adjtime
mv /etc/init.d/hwclock.sh /etc/init.d/hwclock.sh.bak && cat /etc/init.d/hwclock.sh.bak | sed 's#\(HWCLOCKPARS=\)\(.*$\)#\1"\2 --noadjfile"#g' > /etc/init.d/hwclock.sh && chmod +x /etc/init.d/hwclock.sh
cp /etc/environment /etc/environment.bak && echo "BLKID_FILE=/var/local/blkid.tab" >> /etc/environment
mv /etc/resolv.conf /var/tmp/resolv.conf && ln -s /var/tmp/resolv.conf /etc/resolv.conf


