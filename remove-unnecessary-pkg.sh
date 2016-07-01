#!/bin/bash
#
# Copyright (c) 2016 Laurent HUBERT, lau.hub@gma**.com
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.

apt-get remove --purge x11-common alsa-base alsa-utils apache2 lxsession lxpanel gvfs openbox aspell aspell-en vlc gnome-mplayer desktop-base cupsys-client cupsys-bsd foomatic-filters hplip
apt-get autoremove --purge
