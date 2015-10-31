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

. /lib/init/bootclean.sh

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
	
	#Point de montage vers /ro/var/lib/nfs
	create_bind_point /ro/var/lib/nfs /var/lib/nfs
        
	mkdir -p /var/lib/usbutils
	#mkdir -p /var/lib/
	
	cp -p /etc/resolv.conf.static /tmp/resolv.conf
	
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
