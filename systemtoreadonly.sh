#!/bin/bash
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
}

for userhomedir in `ls /home`
do
	USER_DIR=/home/$userhomedir
	#grep -q -F '/usr/bin/welcome_bash' $USER_DIR/.bashrc || echo '/usr/bin/welcome_bash' >> $USER_DIR/.bashrc
	if  grep -q -F '/usr/bin/welcome_bash' $USER_DIR/.bashrc  ; then
		echo "$USER_DIR/.bashrc is already OK"
	else
		echo "Updating $USER_DIR/.bashrc"
		echo '/usr/bin/welcome_bash' >> $USER_DIR/.bashrc
	fi
	if grep -q -F '/usr/bin/update_user_file' $USER_DIR/.bash_logout ; then
		echo "$USER_DIR/.bash_logout is already OK"
	else
		echo "Updating $USER_DIR/.bash_logout"
		echo '/usr/bin/update_user_file' >> $USER_DIR/.bash_logout
	fi
done


