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
        mkdir -p /var/mail       
	mkdir -p /var/lib/apt
	mkdir -p /var/lib/dpkg
	mkdir -p /var/lib/insserv
	mkdir -p /var/lib/ntp
	mkdir -p /var/lib/dhcp
	mkdir -p /var/lib/sudo
	mkdir -p /var/lib/usbutils
	#mkdir -p /var/lib/
	
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
