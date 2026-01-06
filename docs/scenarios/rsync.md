# Internal Backup using BACKUP=RSYNC method

In a previous scenario we discussed "[Internal Backup with rsync to NFS server](netfs_rsync.md)", but now we will use the `BACKUP=RSYNC` way.

The main difference between using rsync in workflow *NETFS* and *RSYNC* is that in the *NETFS* workflow we have the choice to use a network share or an internal file system while
with the *RSYNC* workflow it is always a remote network destination.

Therefore, use a `/etc/rear/local.conf` file that might look like:

    [root@alma rear]# cat /etc/rear/local.conf 
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    #
    ################################
    BACKUP=RSYNC
    BACKUP_URL=rsync://root@192.168.122.1/apps/export/ReaR
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    SSH_ROOT_PASSWORD="relax"
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

While before we used the `BACKUP=NETFS` method and used a mounted NFS file system to archive our system using the backup porgram `rsync` we will now use `rsync`-way to archive our files and directories to our destination path (on the remote backup server).

## Running rear mkbackup

As we did not explicit defined `OUTPUT` it will be set by default to `ISO`.

    [root@alma rear]# rear -v mkbackup
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear mkbackup (PID 16792)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow mkbackup on the normal/original system
    Using autodetected kernel '/boot/vmlinuz-5.14.0-570.58.1.el9_6.x86_64' as kernel in the recovery system
    Creating disk layout
    Overwriting existing disk layout file /var/lib/rear/layout/disklayout.conf
    GRUB found in first bytes on /dev/vda and GRUB 2 is installed, using GRUB2 as a guessed bootloader for 'rear recover'
    Verifying that the entries in /var/lib/rear/layout/disklayout.conf are correct ...
    Creating recovery system root filesystem skeleton layout
    Copying logfile /var/log/rear/rear-alma.log into initramfs as '/tmp/rear-alma-partial-2025-11-25T09:41:30+01:00.log'
    Copying files and directories
    Copying binaries and libraries
    Copying only currently loaded kernel modules (MODULES contains 'loaded_modules')
    Omit copying files in /lib*/firmware/ (FIRMWARE_FILES='no')
    Testing that the recovery system in /var/tmp/rear.DA2ii0bQq7XWa2J/rootfs contains a usable system
    /usr/lib64/systemd/libsystemd-core-252.so requires libraries where 'ldd' shows 'not found'
    /usr/lib64/systemd/libsystemd-core-252.so requires libsystemd-shared-252.so which was not found by 'ldd' but exists as /var/tmp/rear.DA2ii0bQq7XWa2J/rootfs/usr/lib64/systemd/libsystemd-shared-252.so
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (51966884 bytes) in 7 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-alma.iso (67M)
    Copying resulting files to rsync://root@192.168.122.1/apps/export/ReaR location
    Copying resulting files to rsync location
    Saving /var/log/rear/rear-alma.log as rear-alma.log to rsync location
    Calculating size of /
    Calculating size of /boot
    Estimated size of local file systems is 2472 MB
    Calculating size of 192.168.122.1:/apps/export/ReaR
    Creating rsync backup on '192.168.122.1:/apps/export/ReaR'
    Running backup operation
    Backed up 0 MiB [avg 0 KiB/sec]
    Backed up 0 MiB [avg 0 KiB/sec]
    Backed up 0 MiB [avg 0 KiB/sec]
    OK
    Number of deleted files: 0
    Number of regular files transferred: 27,144
    Total file size: 2,193,979,180 bytes
    Total transferred file size: 2,184,347,327 bytes
    Literal data: 2,184,347,327 bytes
    Matched data: 0 bytes
    File list size: 1,507,137
    File list generation time: 0.001 seconds
    File list transfer time: 0.000 seconds
    Total bytes sent: 2,187,249,983
    Total bytes received: 659,501
    
    sent 2,187,249,983 bytes  received 659,501 bytes  59,942,725.59 bytes/sec
    total size is 2,193,979,180  speedup is 1.00 in 43 seconds.
    Exiting rear mkbackup (PID 16792) and its descendant processes ...
    Running exit tasks

It is amazing that the backup using rsync took less then 1 minute!

## Restore the system using rear recover

    RESCUE alma:~ # rear -v recover
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear recover (PID 963)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow recover within the ReaR rescue/recovery system
    root@192.168.122.1's password: 
    root@192.168.122.1's password: 
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
    Restoring rsync backup from '192.168.122.1:/apps/export/ReaR'
    Restore operation
    root@192.168.122.1's password:
    Restored 0 MiB [avg 0 KiB/sec]
    Restored 0 MiB [avg 0 KiB/sec]
    Restored 0 MiB [avg 0 KiB/sec]
    OK
    Number of deleted files: 0
    Number of regular files transferred: 27,145
    Total file size: 2,193,979,180 bytes
    Total transferred file size: 2,184,347,327 bytes
    Literal data: 2,184,347,327 bytes
    Matched data: 0 bytes
    File list size: 1,105,226
    File list generation time: 0.001 seconds
    File list transfer time: 0.000 seconds
    Total bytes sent: 659,937
    Total bytes received: 2,187,287,065
    
    sent 659,937 bytes  received 2,187,287,065 bytes  61,632,309.92 bytes/sec
    total size is 2,193,979,180  speedup is 1.00 in 43 seconds.
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
    Exiting rear recover (PID 963) and its descendant processes ...
    Running exit tasks

Note that in this recovery exercise your will be prompted several times for the root password. If you wnat to avoid this then add the following to the `/etc/rear/local.conf` file:

    COPY_AS_IS+=( '/root/.ssh' )
    SSH_FILES="yes"
    SSH_UNPROTECTED_PRIVATE_KEYS=true


