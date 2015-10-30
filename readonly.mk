###########################
# Readonly part
###########################

RO_APT_CONF_FILE=/etc/apt/apt.conf.d/98aptremountrw

	
###########################
# Readonly part
###########################
.PHONY: ro_directories

readonly: ro_directories /etc/init.d/postmount.sh $(RO_APT_CONF_FILE) /sbin/goro /sbin/gorw /sbin/dhclient-script

ro_directories: 
	mkdir -p /local/home /local/srv 
	#mkdir -p /ro/var /ro/srv /ro/home

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
