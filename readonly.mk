
#
# Copyright (c) 2016 Laurent HUBERT, lau.hub@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.


###########################
# Readonly part
###########################

RO_APT_CONF_FILE=/etc/apt/apt.conf.d/98aptremountrw

BASHRC_FOR_ACTUAL_USERS=$(wildcard /home/*/.bashrc)
BASHRC_FOR_ROOT=/root/.bashrc
	
###########################
# Readonly part
###########################

readonly: ro_directories subscriptsdir /etc/init.d/postmount.sh $(RO_APT_CONF_FILE) /sbin/goro /sbin/gorw /sbin/dhclient-script /etc/init.d/hwclock.sh /etc/environment /etc/fstab /usr/bin/update_user_files /usr/bin/welcome_bash /etc/skel/.bashrc /etc/skel/.bash_logout $(BASHRC_FOR_ACTUAL_USERS)
	
.PHONY: ro_directories subscriptsdir /etc/environment /sbin/dhclient-script /etc/skel/.bashrc /etc/skel/.bash_logout $(BASHRC_FOR_ACTUAL_USERS) 

subscriptsdir:
	mkdir -p /etc/postmount.d
	
ro_directories: 
	mkdir -p /local/home /local/srv 
	mkdir -p /ro/var

/etc/init.d/postmount.sh: services/postmount.sh
	cp $< $@
	@echo Running update-rc.d $(notdir $@) start 10 S
	update-rc.d $(notdir $@) start 10 S

$(RO_APT_CONF_FILE): config-files/aptremountrw.conf
	@echo DISABLED: will not cp $< $@

/sbin/goro: scripts/goro
	cp $< $@

/sbin/gorw: scripts/gorw
	cp $< $@

/sbin/dhclient-script: config-files/dhclient-script
	cp $< $@

/usr/bin/update_user_files: scripts/update_user_files
	cp $< $@
	
/usr/bin/welcome_bash: scripts/welcome_bash
	cp $< $@
	
/etc/skel/.bashrc:
	-grep -q -F '/usr/bin/welcome_bash' $@ || echo '/usr/bin/welcome_bash' >> $@
	
/etc/skel/.bash_logout:
	-grep -q -F '/usr/bin/update_user_files' $@ || echo '/usr/bin/update_user_files' >> $@
	
	
	