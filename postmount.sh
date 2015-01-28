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

case "$1" in
  start|"")
	mkdir -p /var/tmp
        mkdir -p /var/lib
        mkdir -p /var/spool/cron/crontabs
        mkdir -p /var/spool/rsyslog
	CURDIR=`pwd`
	cd /var/spool ; ln -s ../mail
	cd $CURDIR
        mkdir -p /var/log        
        mkdir -p /var/local/srv
	mount --bind /var/local/srv /srv
	
        mkdir -p /var/local/home
        mkdir -p /var/mail
	mkdir -p /var/lib
        #Point de montage vers /ro/var/cache
        mkdir -p /var/cache
        mount --bind /ro/var/cache /var/cache
        
	#Point de montage vers /ro/var/lib/apt
	mkdir -p /var/lib/apt
	mount --bind /ro/var/lib/apt /var/lib/apt
	
	#Point de montage vers /ro/var/lib/dpkg
	mkdir -p /var/lib/dpkg
	mount --bind /ro/var/lib/dpkg /var/lib/dpkg
	
	#Point de montage vers /ro/var/lib/dbus
	mkdir -p /var/lib/dbus
	mount --bind /ro/var/lib/dbus /var/lib/dbus
	
	mkdir -p /var/lib/insserv
	mkdir -p /var/lib/ntp
	mkdir -p /var/lib/dhcp

	#Copie les données provenant de /var/lib/sudo
	mkdir -p /var/lib/sudo
	cp -pr /ro/var/lib/sudo/* /var/lib/sudo/
	
        #Copie les données provenant de /var/lib/nfs
        mkdir -p /var/lib/nfs
        mount --bind /ro/var/lib/nfs /var/lib/nfs
        
	mkdir -p /var/lib/usbutils
	#mkdir -p /var/lib/
	
	cp -p /etc/resolv.conf.static /tmp/resolv.conf
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
