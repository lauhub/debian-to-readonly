# Make a Debian system run as read-only

## Information

This is a basis to transform a Debian installation to run without read-write access to drives.

It is intended to run Debian Wheezy on headless systems but should probably work with Jessie.

##How it works

###Reference
The   [Debian/ReadonlyRoot page](https://wiki.debian.org/ReadonlyRoot) is the basis of this work.

It says that no files inside `/etc` should be writable, and gives recipes to make this happen.

###Policy
The goal is to have a system with a read only rootfs, but which can easily reverted back (at runtime) in a read-write state.

To do so I chose :

  1. to make some files/directories read-only (even if they should be writable according to [Debian/ReadonlyRoot page](https://wiki.debian.org/ReadonlyRoot)) but allow them to become writable using some scripts (`goro` and `gorw` scripts).
  2. to duplicate/fake some files/directories to make them writable but non-persistant (using tmpfs)


### Overview
Basically, the /var and /home directories should always be writable. But, it is chosen here to make **some parts of /var and /home read-only** (not fully writable).

To do so, there are the main steps during boot:

  1. Bind /var to /ro/var and /home to /ro/home (/etc/fstab)
  2. Create binds from /ro/var/[some subdirs] to /var (done by /etc/init.d/postmount.sh)
  3. Create writable dir/files (e.g. /var/lib, /var/local/home, ...) that will bind to its twin inside /ro (e.g. /ro/var/lib, /ro/home, ...) (done by /etc/init.d/postmount.sh)
  4. Replace some files with symlinks or duplicate files to use the files that are actually in the readonly FS as writable files (done by /etc/init.d/postmount.sh)

`/etc/init.d/postmount.sh` is a script that is called during startup just after `mountall`

So we have this:

```
/ro/var (rootfs) -->> /var (the real one on rootfs)
/var/[somedir] -->> /ro/var/[somedir] (rootfs)
/home -->> /var/local/home (tmpfs) -->> /var (the real one on rootfs)
```

### Switching from read-only to read-write mode
Switching from read-only to read-write mode and backward is done using two scripts:
  
  -  goro (go Read Only)
  -  gorw (go Read Write)
  
These two scripts update all the bindings accordingly. This is done with two subscripts that are created by `postmount.sh` script:

  -  `/tmp/remountro`
  -  `/tmp/remountrw`
  

### Some details

The information in this section is not exhaustive. See source code for details.

`postmount.sh` script will create some directories in /var (tmpfs):

  -  `/var/tmp`
  -  `/var/lib`
  -  `/var/spool/cron/crontabs`
  -  `/var/spool/rsyslog`
  -  `/var/log`
  -  `/var/local/srv` (`/srv` will be a symlink to this one)
  -  `/var/mail` (`/var/spool/mail` will be a symlink to this one)
  
*The content of this directories is not persistent.*

`postmount.sh` script will create bind mount points :

  -  `/ro/var/lib/apt` -->>  `/var/lib/apt`
  -  `/ro/var/lib/cache` -->>  `/var/lib/cache`
  -  `/ro/var/lib/dbus` -->>  `/var/lib/dbus`
  -  `/ro/var/lib/dpkg` -->>  `/var/lib/dpkg`
  -  `/ro/var/lib/nfs` -->>  `/var/lib/nfs`

`postmount.sh` script will duplicate some data (e.g. copy the original content from `/ro/var/lib/sudo` data to the temp dir `/var/lib/sudo`) :
	-  `cp -pr /ro/var/lib/sudo/* /var/lib/sudo/`

`postmount.sh` script will replace the `/etc/resolv.conf` with a symlink to `/tmp/resolv.conf`

### Configuration scripts
`remove-unnecessary-pkg.sh` is  just used to remove packages that should not be useful on headless system.

`make -f readonly.mk` updates some files (scrits, dhclient script, ...) to make the system usable as a read only system.

`systemtoreadonly.sh` modifies some files in the system to with the same purpose.

All these scripts must be used as root.


## How to use it (installation steps)
### First step

Execute the following commands:

    # sudo remove-unnecessary-pkg.sh

    # sudo make -f readonly.mk


Edit /etc/fstab (without putting `ro` yet) to make it match your needs (the rootfs which is mounted to `/` should point to the correct device, use UUID if needed).

The execute the following command:

     # sudo systemtoreadonly.sh

Reboot your system.

If everything is correct, replace ro with rw in /etc/fstab for the following entries :

- `/`
- `/ro/var`
- `/ro/home`

#TODO
A lot of work: cleaning, testing, enhancing...

A *Jessie tested* version

# Disclaimer
This program comes without any warranty, to the extent permitted by applicable law. Create a backup of your files before using and make sure you can revert back if necessary.
