#! /bin/sh
#
# Copyright (c) 2016 Laurent HUBERT, lau.hub@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
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
#
### END INIT INFO
PATH=/sbin:/bin
. /lib/init/vars.sh

. /lib/lsb/init-functions

BIND_MOUNT_OPTIONS="-o bind,ro"

REMOUNT_RW_FILE=/tmp/remountrw
REMOUNT_RO_FILE=/tmp/remountro

# Creates a bind point that will point to the real directory. 
#
#
# By default, this directory will be read-only.
# But calling gorw script will make it rw.
# Calling goro script will make it goro.
# That is why we add to $REMOUNT_Rx_FILE a line. This will allow gorX scripts to 
# take into account this script.
# First argument: the directory that contain original values
# Second argument: the mount point that will be see as the original file, 
#                  but without (or with) RW permissions (according to if gorw or
#                  goro scripts were called).
create_bind_point(){
	mkdir -p $2
	mount $BIND_MOUNT_OPTIONS $1 $2
	echo "mount -o remount,rw,bind $1 $2" >> $REMOUNT_RW_FILE
    echo "mount -o remount,ro,bind $1 $2" >> $REMOUNT_RO_FILE
}

duplicate_home_subdirs(){
	#This one should be /ro/home
	SOURCE_HOME_DIR=$1 
	#This one should be /var/local/home
	TARGET_HOME_DIR=$2
	
	#Each file
	for directory in `ls $SOURCE_HOME_DIR` ; do
		#User is the same as directory
		user=$directory
		
		#Create target
		mkdir -p $TARGET_HOME_DIR/$directory
		for source in `ls -a $SOURCE_HOME_DIR/$directory`
		do
			case $source in
			.lesshst | .bash* | .gitconfig | .Xauthority | .profile)
				cp $SOURCE_HOME_DIR/$directory/$source $TARGET_HOME_DIR/$directory/
				;;
			.ssh | .ne)
				cp -r $SOURCE_HOME_DIR/$directory/$source $TARGET_HOME_DIR/$directory/
				;;
			. | ..)
				;;
			*)
				ln -s $SOURCE_HOME_DIR/$directory/$source $TARGET_HOME_DIR/$directory/
			esac
		done
		chown -R $user:$user $TARGET_HOME_DIR/$directory
		
	done
}


case "$1" in
  start|"")
	#Adding log message
	log_action_begin_msg "Creating bind points"
  	
	#We assume here that /var is mounted into a RAM FS (tmpfs)
	#So /var will always be RW.
	#But, we make sure that
	
	#Temporary script files
	#These files will contain which remount command are to be called when remounting
	#RW or RO
	#e.g. goro script will call the REMOUNT_RO_FILE
	echo '#!/bin/bash' > $REMOUNT_RO_FILE
	echo '#!/bin/bash' > $REMOUNT_RW_FILE
	chmod +x $REMOUNT_RO_FILE
	chmod +x $REMOUNT_RW_FILE
	
	#RW directories are created here
	#mkdir -p /var/tmp
	#mkdir -p /var/lib
	#mkdir -p /var/spool/cron/crontabs
	#mkdir -p /var/spool/rsyslog
	#CURDIR=`pwd`
	#cd /var/spool ; ln -s ../mail
	#cd $CURDIR
	
	#The log directory:
	#mkdir -p /var/log

	#/srv must be mounted into a tmpfs filesystem
	#In order to be RW
	mkdir -p /var/local/srv
	mount --bind /var/local/srv /srv
	
	#mkdir -p /var/mail
	#mkdir -p /var/lib
	
	### ------------------------------ ###
	# Read-Only directories by default
	### ------------------------------ ###
	
	#Mount point to /ro/var/cache
	#create_bind_point /ro/var/cache /var/cache
        
	#Mount point to /ro/var/lib/apt
	#create_bind_point /ro/var/lib/apt /var/lib/apt
	
	#Mount point to /ro/var/lib/dpkg
	#create_bind_point /ro/var/lib/dpkg /var/lib/dpkg
	
	#Mount point to /ro/var/lib/dbus
	#create_bind_point /ro/var/lib/dbus /var/lib/dbus
	
	#Mount point to /ro/var/lib/usbutils
	#create_bind_point /ro/var/lib/usbutils /var/lib/usbutils
	### ------------------------------ ###
	
	#mkdir -p /var/lib/insserv
	#mkdir -p /var/lib/ntp
	#mkdir -p /var/lib/dhcp

	#Duplicates the data from the original /var/lib/sudo to temp RW directory
	#mkdir -p /var/lib/sudo
	#cp -pr /ro/var/lib/sudo/* /var/lib/sudo/
	
	#Taking into account possibly present dir: /ro/var/lib/nfs
	#It will be RO
	#if [ -d /ro/var/lib/nfs ] ; then
	#	create_bind_point /ro/var/lib/nfs /var/lib/nfs
	#fi
	
	#Taking into account possibly present dir: /ro/var/lib/monit
	#It will be RW (monit needs a writable dir)
	#if [ -d /ro/var/lib/monit ] ; then
	#	mkdir -p /var/lib/monit
	#fi
	
	#usbutils writable file
	#mkdir -p /var/lib/usbutils
	### ------------------------------ ###
	# home directory
	### ------------------------------ ###
	#This one is specific.
	#We want it to be writable at any time, but whenever a user logs in, 
	#it will copy the main files from the /ro/home directory
	#This last thing is done via .bash_logout script
	#
	#duplicate_home_subdirs /ro/home /var/local/home
	#And last but not least, the bind point:
	mount --bind /var/local/home /home
	
	### ------------------------------ ###
	# Resolv.conf
	### ------------------------------ ###
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
	### ------------------------------ ###
	
	
	#Now add the /ro/var to temp scripts, in order to allow it to be writable if necessary
	#echo "mount -o remount,rw,bind /ro/var"  >> $REMOUNT_RW_FILE
	#echo "mount -o remount,ro,bind /ro/var"  >> $REMOUNT_RO_FILE
	echo "mount -o remount,rw,bind /ro/home" >> $REMOUNT_RW_FILE
	echo "mount -o remount,ro,bind /ro/home" >> $REMOUNT_RO_FILE
    
	
	log_action_end_msg 0
	
	log_action_begin_msg "Executing subscripts"
	
	#Run plugable scripts
	run-parts --arg="start" /etc/postmount.d/
	
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
  test)
	# No-op
	duplicate_home_subdirs /home /tmp/output
	;;
  *)
	echo "Usage: postmount.sh [start|stop]" >&2
	exit 3
	;;
esac


