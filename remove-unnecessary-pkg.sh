#!/bin/bash

apt-get remove --purge x11-common alsa-base alsa-utils apache2 lxsession lxpanel gvfs openbox aspell aspell-en vlc gnome-mplayer desktop-base cupsys-client cupsys-bsd foomatic-filters hplip
apt-get autoremove --purge
