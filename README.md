# Make a Debian system run as read-only

## Information

This is a basis to transform a Debian installation to run without read-write access to drives.

It is intended to run Debian Wheezy on headless systems.


## How to use it
### First step

    sudo remove-unnecessary-pkg.sh

    sudo make -f readonly.mk


Edit /etc/fstab (without putting ro yet)

     systemtoreadonly.sh

Reboot your system

If everything is correct, replace ro with rw in /etc/fstab for the following entries :

- /,
- /ro/var)
