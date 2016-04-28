###########################
# Readonly part
###########################

RO_APT_CONF_FILE=/etc/apt/apt.conf.d/98aptremountrw

	
###########################
# Readonly part
###########################
.PHONY: ro_directories subscriptsdir /etc/environment /sbin/dhclient-script

readonly: ro_directories subscriptsdir /etc/init.d/postmount.sh $(RO_APT_CONF_FILE) /sbin/goro /sbin/gorw /sbin/dhclient-script /etc/init.d/hwclock.sh /etc/environment /etc/fstab

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
	cp $< $@

/sbin/goro: scripts/goro
	cp $< $@

/sbin/gorw: scripts/gorw
	cp $< $@

/sbin/dhclient-script: config-files/dhclient-script
	cp $< $@

/etc/fstab: config-files/fstab.nand
	cp $< $@
	