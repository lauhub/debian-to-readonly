#!/bin/bash
apt-get remove --purge x11-common alsa-base alsa-utils apache2 lxsession lxpanel gvfs openbox aspell aspell-en vlc gnome-mplayer desktop-base cupsys-client cupsys-bsd foomatic-filters hplip
apt-get autoremove --purge

cp /etc/adjtime /var/local/adjtime
rm /etc/adjtime; ln -s /var/local/adjtime /etc/adjtime
mv /etc/init.d/hwclock.sh /etc/init.d/hwclock.sh.bak && cat /etc/init.d/hwclock.sh.bak | sed 's#\(HWCLOCKPARS=\)\(.*$\)#\1"\2 --noadjfile"#g' > /etc/init.d/hwclock.sh && chmod +x /etc/init.d/hwclock.sh
cp /etc/environment /etc/environment.bak && echo "BLKID_FILE=/var/local/blkid.tab" >> /etc/environment
mv /etc/resolv.conf /var/tmp/resolv.conf && ln -s /var/tmp/resolv.conf /etc/resolv.conf
