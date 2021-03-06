#!/bin/bash
#
# Copyright (c) 2016 Laurent HUBERT, lau.hub@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.

mkdir -p /local/home /local/srv 

#Creates the places where we will bind original files to:
mkdir -p /ro/var /ro/srv /ro/home

if [[ ! -L /etc/adjtime ]] ;  then 
	echo "Making /etc/adjtime a link"
	cp /etc/adjtime /var/local/adjtime
	rm /etc/adjtime; ln -s /var/local/adjtime /etc/adjtime
	mv /etc/init.d/hwclock.sh /etc/init.d/hwclock.sh.bak && cat /etc/init.d/hwclock.sh.bak | sed 's#\(HWCLOCKPARS=\)\(.*$\)#\1"\2 --noadjfile"#g' > /etc/init.d/hwclock.sh && chmod +x /etc/init.d/hwclock.sh
else
	echo "/etc/adjtime is already a link"
fi

grep -q -F 'BLKID_FILE=/var/local/blkid.tab' /etc/environment || cp /etc/environment /etc/environment.bak && echo "BLKID_FILE=/var/local/blkid.tab" >> /etc/environment

if [[ ! -L /etc/resolv.conf ]] ;  then 
	echo "Making /etc/resolv.conf a link"
	mv /etc/resolv.conf /tmp/resolv.conf && ln -s /tmp/resolv.conf /etc/resolv.conf
else
	echo "/etc/resolv.conf is already a link"
fi


append_text_to_file_if_needed(){
	text=$1
	filepath=$2
	if  grep -q -F "$1" $filepath  ; then
		echo "$filepath is already up-to-date."
	else
		echo "Updating $filepath"
		echo "$1" >> $filepath
	fi
}

for userhomedir in `ls /home`
do
	USER_DIR=/home/$userhomedir
	#grep -q -F '/usr/bin/welcome_bash' $USER_DIR/.bashrc || echo '/usr/bin/welcome_bash' >> $USER_DIR/.bashrc
	append_text_to_file_if_needed '/usr/bin/welcome_bash' $USER_DIR/.bashrc 
	append_text_to_file_if_needed '/usr/bin/update_user_files' $USER_DIR/.bash_logout 
done

append_text_to_file_if_needed "/var             /ro/var         none     bind,ro               0 0" /etc/fstab
append_text_to_file_if_needed "/home             /ro/home        none     bind,ro               0 0" /etc/fstab
