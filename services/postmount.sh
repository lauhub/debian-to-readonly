#! /bin/sh
### BEGIN INIT INFO
# Provides:          postmount
# Required-Start:    mountall
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# X-Start-Before:    mountall-bootclean
# Short-Description: create readonly var directories at boot.
# Description:       Create all var subdirectories and eventually
#                    copy some information from original /var/lib
#                    which should be into /rootfsvar
### END INIT INFO
PATH=/sbin:/bin
. /lib/init/vars.sh

. /lib/lsb/init-functions

BIND_MOUNT_OPTIONS="-o bind,ro"

REMOUNT_RW_FILE=/tmp/remountrw
REMOUNT_RO_FILE=/tmp/remountro


create_bind_point(){
	mkdir -p $2
	mount $BIND_MOUNT_OPTIONS $1 $2
	echo "mount -o remount,rw,bind $1 $2" >> $REMOUNT_RW_FILE
    echo "mount -o remount,ro,bind $1 $2" >> $REMOUNT_RO_FILE
}


case "$1" in
  start|"")
	#Adding log message
	log_action_begin_msg "Creating bind points"
  	  
	#Fichiers temporaire pour le remontage en rw/ro
    echo '#!/bin/bash' > $REMOUNT_RO_FILE
	echo '#!/bin/bash' > $REMOUNT_RW_FILE
	chmod +x $REMOUNT_RO_FILE
	chmod +x $REMOUNT_RW_FILE

	mkdir -p /var/tmp
	mkdir -p /var/lib
	mkdir -p /var/spool/cron/crontabs
	mkdir -p /var/spool/rsyslog
	CURDIR=`pwd`
	cd /var/spool ; ln -s ../mail
	cd $CURDIR
	mkdir -p /var/log

	#/srv must be mounted into a tmpfs filesystem
	mkdir -p /var/local/srv
	mount --bind /var/local/srv /srv
	
	mkdir -p /var/mail
	mkdir -p /var/lib
	
	#Point de montage vers /ro/var/cache
	create_bind_point /ro/var/cache /var/cache
        
	#Point de montage vers /ro/var/lib/apt
	create_bind_point /ro/var/lib/apt /var/lib/apt
	
	#Point de montage vers /ro/var/lib/dpkg
	create_bind_point /ro/var/lib/dpkg /var/lib/dpkg
	
	#Point de montage vers /ro/var/lib/dbus
	create_bind_point /ro/var/lib/dbus /var/lib/dbus
	
	mkdir -p /var/lib/insserv
	mkdir -p /var/lib/ntp
	mkdir -p /var/lib/dhcp

	#Copie les données provenant de /var/lib/sudo
	mkdir -p /var/lib/sudo
	cp -pr /ro/var/lib/sudo/* /var/lib/sudo/
	
	#Taking into account possibly present dir: /ro/var/lib/nfs
	if [ -d /ro/var/lib/nfs ] ; then
		create_bind_point /ro/var/lib/nfs /var/lib/nfs
	fi
	
	#Taking into account possibly present dir: /ro/var/lib/monit
	if [ -d /ro/var/lib/monit ] ; then
		mkdir -p /var/lib/monit
	fi
	
	mkdir -p /var/lib/usbutils
	#mkdir -p /var/lib/
	
	#The most tricky part: resolv.conf
	
	ORIGINAL_RESOLV_CONF=/etc/resolv.conf
	READONLY_RESOLV_CONF=/tmp/resolv.conf
	echo "About to update resolv.conf" >> /var/log/pads_resolv.log
	ls -l /etc/resolv.conf  >> /var/log/pads_resolv.log 2>&1

	if [ -f $ORIGINAL_RESOLV_CONF ] ; then
		#We have a file here
		if [ ! -L $ORIGINAL_RESOLV_CONF ] ; then
			#It is not a symlink
                        mount -o remount,rw /
			#We copy it to the READONLY_RESOLV_CONF
			cp -p $ORIGINAL_RESOLV_CONF $READONLY_RESOLV_CONF  >> /var/log/pads_resolv.log 2>&1
			rm $ORIGINAL_RESOLV_CONF  >> /var/log/pads_resolv.log 2>&1
			ln -s $READONLY_RESOLV_CONF $ORIGINAL_RESOLV_CONF  >> /var/log/pads_resolv.log 2>&1
			
			echo "Created a link for resolv.conf" >> /var/log/pads_resolv.log
                        mount -o remount,ro /
		fi
		#ELSE: It is already a symlink: nothing to do
	else
		#Nothing at this path.
		#We create the target resolv.conf
		touch $READONLY_RESOLV_CONF  >> /var/log/pads_resolv.log 2>&1
		#And link it from /etc/resolv.conf
                mount -o remount,rw /
		ln -s $READONLY_RESOLV_CONF $ORIGINAL_RESOLV_CONF  >> /var/log/pads_resolv.log 2>&1
		echo "updated a link for resolv.conf" >> /var/log/pads_resolv.log 2>&1
                mount -o remount,ro /
	fi
	
	ls -l /etc/resolv.conf  >> /var/log/pads_resolv.log 2>&1

	echo "mount -o remount,rw,bind /ro/var" >> $REMOUNT_RW_FILE
    echo "mount -o remount,ro,bind /ro/var" >> $REMOUNT_RO_FILE
    
	
	log_action_end_msg 0
	
	exit $?
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	# No-op
	;;
  *)
	echo "Usage: postmount.sh [start|stop]" >&2
	exit 3
	;;
esac

:
