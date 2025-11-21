# External backup using restic

[Restic](https://restic.net/) is a modern backup program that can back up your files from Linux, BSD, MacOS, or Windows. Restic is easy, being a single executable that you can run without a complex setup. Restic performs incremental backups, only transferring the parts that actually changed in the files you back up.

Currently there is no workflow in ReaR that supports restic. You can [sponsor](https://relax-and-recover.org/support/sponsors) us to create a `BACKUP=RESTIC` workflow inside ReaR.

However, do not despare as the EXTERNAL workflow can be used to make backups and restores through ReaR. It is not official supported by the ReaR maintainers, but it can be done. Be aware that you cannot complain to us if it doesn't work as what we describe below is not a real integration in ReaR, but rather a last tool to perform the backup and/or recover yourself with your own favorite backup tool.

## Install the restic software

On RedHat alike OSes you first of all need to install epel-release:

    # dnf install epel-release

Once the epel repository is available is available install the restic application with the command:

    # dnf install restic

For other ways to install restic see the [installation](https://restic.readthedocs.io/en/latest/020_installation.html) page of the docmentation.

## Prepare a backup repository

The instructions are nicely explained in [preparing a new repo](https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html) section of the documentation.
Also, the method you want to use to reach your repo on the backup server must be carefully selected.

We use the *sftp* method, therefore, the secure shell access to the backup server has to work without entering passwords.

Before we can make backups we need to initialize a restic backup repository with the `init` option and thereby provide a really good password:

    # restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup init
    enter password for new repository: restic

Of course, as we are just testing out restic our password really sucks - do NOT use a simple password for production!

To avoid that we need to enter the password each time we run `restic` we chose to save the password in a special file:

    # cat /etc/restic-password
    restic

And, we changed to permissions of the file `/etc/restic-password` to mode 0400.

## Excluding files/directories from the backup scheme

 In order to avoid too much data being backed up, or even avoiding hangs or never ending backups create an exclude file for `restic`:

    # cat /etc/restic_exclude_files 
    /proc
    /sys
    /media
    /mnt
    /run
    /tmp
    /var/tmp

## Configring ReaR

Of course we assume that the `rear` package was already installed, if not, do this first.

You can create a `/etc/rear/local.conf` or `/etc/rear/restic.conf file which contains:

    [root@alma rear]# cat restic.conf 
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    
    BACKUP=EXTERNAL
    OUTPUT=ISO
    OUTPUT_URL=nfs://192.168.122.1/apps/export/RBME
    
    COPY_AS_IS+=( '/etc/restic_exclude_files' '/etc/restic-password' '/root/.ssh/' )
    SSH_FILES="yes"
    SSH_UNPROTECTED_PRIVATE_KEYS=true
    
    REQUIRED_PROGS+=( 'restic' )
    EXTERNAL_BACKUP="restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup backup / /boot --one-file-system --exclude-file /etc/restic_exclude_files --password-file /etc/restic-password"
    EXTERNAL_RESTORE="restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup restore latest --target /mnt/local --password-file /etc/restic-password"
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    SSH_ROOT_PASSWORD="relax"
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

## Running ReaR mkbackup

To create a ReaR rescue image together with a full restic backup just run:

    [root@alma rear]# rear -v -C restic mkbackup
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear mkbackup (PID 30777)
    Using log file: /var/log/rear/rear-alma.log
    Sourcing additional configuration file '/etc/rear/restic.conf'
    Running workflow mkbackup on the normal/original system
    Using autodetected kernel '/boot/vmlinuz-5.14.0-570.58.1.el9_6.x86_64' as kernel in the recovery system
    Creating disk layout
    Overwriting existing disk layout file /var/lib/rear/layout/disklayout.conf
    GRUB found in first bytes on /dev/vda and GRUB 2 is installed, using GRUB2 as a guessed bootloader for 'rear recover'
    Verifying that the entries in /var/lib/rear/layout/disklayout.conf are correct ...
    Creating recovery system root filesystem skeleton layout
    Copying logfile /var/log/rear/rear-alma.log into initramfs as '/tmp/rear-alma-partial-2025-11-20T15:11:54+01:00.log'
    Copying files and directories
    Copying binaries and libraries
    Copying only currently loaded kernel modules (MODULES contains 'loaded_modules')
    Omit copying files in /lib*/firmware/ (FIRMWARE_FILES='no')
    Testing that the recovery system in /var/tmp/rear.RblpXGZBM4GbG6M/rootfs contains a usable system
    /usr/lib64/systemd/libsystemd-core-252.so requires libraries where 'ldd' shows 'not found'
    /usr/lib64/systemd/libsystemd-core-252.so requires libsystemd-shared-252.so which was not found by 'ldd' but exists as /var/tmp/rear.RblpXGZBM4GbG6M/rootfs/usr/lib64/systemd/libsystemd-shared-252.so
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (60736875 bytes) in 9 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-alma.iso (75M)
    Copying resulting files to nfs location
    Saving /var/log/rear/rear-alma.log as rear-alma.log to nfs location
    Copying result files '/var/lib/rear/output/rear-alma.iso /var/tmp/rear.RblpXGZBM4GbG6M/tmp/VERSION /var/tmp/rear.RblpXGZBM4GbG6M/tmp/README /var/tmp/rear.RblpXGZBM4GbG6M/tmp/rear-alma.log' to /var/tmp/rear.RblpXGZBM4GbG6M/outputfs/alma at nfs location
    Running external backup command
    Finished external backup command
    Exiting rear mkbackup (PID 30777) and its descendant processes ...
    Running exit tasks

## Recovering using ReaR and restic

    RESCUE alma:~ # rear -v -C restic recover
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear recover (PID 576)
    Using log file: /var/log/rear/rear-alma.log
    Sourcing additional configuration file '/etc/rear/restic.conf'
    Running workflow recover within the ReaR rescue/recovery system
    Comparing disks
    Device vda has expected (same) size 8589934592 bytes (will be used for 'recover')
    Disk configuration looks identical
    Proceed with 'recover' (yes) otherwise manual disk layout configuration is enforced
    (default 'yes' timeout 30 seconds)
    yes
    User confirmed to proceed with 'recover'
    Start system layout restoration.
    Disk '/dev/vda': creating 'msdos' partition table
    Disk '/dev/vda': creating partition number 1 with name 'primary'
    Disk '/dev/vda': creating partition number 2 with name 'primary'
    Creating LVM PV /dev/vda2
    Restoring LVM VG 'almalinux'
    Sleeping 3 seconds to let udev or systemd-udevd create their devices...
    Creating filesystem of type xfs with mount point / on /dev/mapper/almalinux-root.
    Mounting filesystem /
    Creating filesystem of type xfs with mount point /boot on /dev/vda1.
    Mounting filesystem /boot
    Creating swap on /dev/mapper/almalinux-swap
    Disk layout created.
    Running external restore command
    Finished external restore command
    Created SELinux /mnt/local/.autorelabel file : after reboot SELinux will relabel all files
    Recreating directories (with permissions) from /var/lib/rear/recovery/directories_permissions_owner_group
    Renamed LVM devices file /mnt/local//etc/lvm/devices/system.devices to /mnt/local//etc/lvm/devices/system.devices.rearbak
    to prevent LVM problems in the recovered system, verify that the file
    is correct after booting the recovered system and move it back, or
    regenerate it using vgimportdevices.
    Migrating disk-by-id mappings in certain restored files in /mnt/local to current disk-by-id mappings ...
    Running dracut...
    Updated initrd with new drivers for kernel 5.14.0-503.11.1.el9_5.x86_64.
    Running dracut...
    Updated initrd with new drivers for kernel 5.14.0-570.58.1.el9_6.x86_64.
    Installing GRUB2 boot loader...
    Determining where to install GRUB2 (no GRUB2_INSTALL_DEVICES specified)
    Found possible boot disk /dev/vda - installing GRUB2 there
    Finished 'recover'. The target system is mounted at '/mnt/local'.
    Exiting rear recover (PID 576) and its descendant processes ...
    Running exit tasks

### References

* [Restic - Backups done right](https://restic.net/)

* [Restic GitHub home page](https://github.com/restic/restic)

* [Restic Documentation](https://restic.readthedocs.io/en/latest/)
