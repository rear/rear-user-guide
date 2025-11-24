# Internal Backup with rsync to NFS server

We already discussed internal backup with GNU tar, but we could also use `rsync` instead of `tar` to make an archive of our system
to a NFS server. A simple `/etc/rear/local.conf` configuration file could like like:

    [root@alma rear]# cat /etc/rear/local.conf 
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    #
    ################################
    BACKUP=NETFS
    BACKUP_URL=nfs://192.168.122.1/apps/export/ReaR
    BACKUP_PROG=rsync
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    SSH_ROOT_PASSWORD="relax"
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

To use `rsync` as backup program we need to add `BACKUP_PROG=rsync` to our configuration file.

Remember, when `OUTPUT` is not explicit mentioned then by default it will be set to `ISO`.

## Running rear mkbackup

As usual to make a rescue ISO image to the same location as defined with `BACKUP_URL` (if `OUTPUT_URL` is not
defined then it will be same as `BACKUP_URL`).

    [root@alma rear]# rear -v mkbackup
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear mkbackup (PID 2159)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow mkbackup on the normal/original system
    Using backup archive '/var/tmp/rear.pMoleCmgUkWxB10/outputfs/alma/backup'
    Using autodetected kernel '/boot/vmlinuz-5.14.0-570.58.1.el9_6.x86_64' as kernel in the recovery system
    Creating disk layout
    Overwriting existing disk layout file /var/lib/rear/layout/disklayout.conf
    GRUB found in first bytes on /dev/vda and GRUB 2 is installed, using GRUB2 as a guessed bootloader for 'rear recover'
    Verifying that the entries in /var/lib/rear/layout/disklayout.conf are correct ...
    Creating recovery system root filesystem skeleton layout
    Copying logfile /var/log/rear/rear-alma.log into initramfs as '/tmp/rear-alma-partial-2025-11-24T11:30:21+01:00.log'
    Copying files and directories
    Copying binaries and libraries
    Copying only currently loaded kernel modules (MODULES contains 'loaded_modules')
    Omit copying files in /lib*/firmware/ (FIRMWARE_FILES='no')
    Testing that the recovery system in /var/tmp/rear.pMoleCmgUkWxB10/rootfs contains a usable system
    /usr/lib64/systemd/libsystemd-core-252.so requires libraries where 'ldd' shows 'not found'
    /usr/lib64/systemd/libsystemd-core-252.so requires libsystemd-shared-252.so which was not found by 'ldd' but exists as /var/tmp/rear.pMoleCmgUkWxB10/rootfs/usr/lib64/systemd/libsystemd-shared-252.so
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (53889600 bytes) in 9 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-alma.iso (69M)
    Copying resulting files to nfs location
    Saving /var/log/rear/rear-alma.log as rear-alma.log to nfs location
    Copying result files '/var/lib/rear/output/rear-alma.iso /var/tmp/rear.pMoleCmgUkWxB10/tmp/VERSION /var/tmp/rear.pMoleCmgUkWxB10/tmp/README /var/tmp/rear.pMoleCmgUkWxB10/tmp/rear-alma.log' to /var/tmp/rear.pMoleCmgUkWxB10/outputfs/alma at nfs location
    Making backup (using backup method NETFS)
    Creating rsync archive '/var/tmp/rear.pMoleCmgUkWxB10/outputfs/alma/backup'
    Preparing archive operation
    Archived 298 MiB [avg 27741 KiB/sec] 
    Archived 282 MiB [avg 13750 KiB/sec] 
    ...
    Archived 2041 MiB [avg 758 KiB/sec] 
    Archived 2076 MiB [avg 768 KiB/sec] 
    OK
    Archived 2076 MiB in 2777 seconds [avg 765 KiB/sec]
    Exiting rear mkbackup (PID 2159) and its descendant processes ...
    Running exit tasks

Between two full archive runs we could use `rear mkbackuponly` to archive the files/directories that were added or changed after the previous `rear mkbackup` run. 
This only takes a minute or so, but the drawback is that you only have one copy of your system and a point in time recovery is not possible with this method. 
For example with [Rsync Backup Made Easy (RBME)](rbme.md) a recovery in time is possible albeit to a specific date (not to a specifi hour).


## The NFS server contains the archive backup

    [root@rocky alma]# ll
    total 72216
    dr-xr-xr-x. 18 root root     4096 Nov  6 10:35 backup
    -rw-------.  1 root root  2376360 Nov 24 12:17 backup.log
    -rw-------.  1 root root      202 Nov 24 11:31 README
    -rw-------.  1 root root 71415808 Nov 24 11:31 rear-alma.iso
    -rw-------.  1 root root   137267 Nov 24 11:31 rear-alma.log
    -rw-------.  1 root root        0 Nov 24 12:17 selinux.autorelabel
    -rw-------.  1 root root      268 Nov 24 11:31 VERSION

and the `backup` sub-directory contains the archives files/directories of our client:

    [root@rocky alma]# ll backup
    total 20
    dr-xr-xr-x.  2 root root    6 Oct  2  2024 afs
    lrwxrwxrwx.  1 root root    7 Oct  2  2024 bin -> usr/bin
    dr-xr-xr-x.  5 root root 4096 Nov  6 11:00 boot
    drwxr-xr-x.  2 root root    6 Nov 24 11:18 dev
    drwxr-xr-x. 84 root root 8192 Nov 24 11:18 etc
    drwxr-xr-x.  3 root root   18 Nov  6 10:38 home
    lrwxrwxrwx.  1 root root    7 Oct  2  2024 lib -> usr/lib
    lrwxrwxrwx.  1 root root    9 Oct  2  2024 lib64 -> usr/lib64
    drwxr-xr-x.  2 root root    6 Oct  2  2024 media
    drwxr-xr-x.  2 root root    6 Oct  2  2024 mnt
    drwxr-xr-x.  2 root root    6 Oct  2  2024 opt
    dr-xr-xr-x.  2 root root    6 Nov 24 11:18 proc
    drwxr-x---.  5 root root  176 Nov 13 16:51 root
    drwxr-xr-x.  2 root root    6 Nov 24 11:18 run
    lrwxrwxrwx.  1 root root    8 Oct  2  2024 sbin -> usr/sbin
    drwxr-xr-x.  2 root root    6 Oct  2  2024 srv
    dr-xr-xr-x.  2 root root    6 Nov 24 11:18 sys
    drwxrwxrwt.  2 root root    6 Nov 24 11:30 tmp
    drwxr-xr-x. 12 root root  144 Nov  6 10:35 usr
    drwxr-xr-x. 19 root root 4096 Nov  6 10:41 var

## Recovering with NETFS method and rsync

To recover the system boot from the ISO image and run command `rear -v recover`:

    RESCUE alma:~ # rear -v recover
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear recover (PID 577)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow recover within the ReaR rescue/recovery system
    Starting required daemons for NFS: RPC portmapper (portmap or rpcbind) and rpc.statd if available.
    Started RPC portmapper 'rpcbind'.
    RPC portmapper 'rpcbind' available.
    Started rpc.statd.
    RPC status rpc.statd available.
    Started rpc.idmapd.
    Using backup archive '/tmp/rear.MyqwZAalENdB4AH/outputfs/alma/backup'
    Calculating backup archive size
    Backup archive size is 2.1G	/tmp/rear.MyqwZAalENdB4AH/outputfs/alma/backup 
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
    Restoring from '/tmp/rear.MyqwZAalENdB4AH/outputfs/alma/backup' (restore log in /var/lib/rear/restore/recover.backup.577.restore.log) ...
    Backup restore program 'rsync' started in subshell (PID=2129)
    Restoring for 10 seconds... 
    Restoring for 20 seconds... 
    Restoring for 30 seconds... 
    OK
    Backup restore program 'rsync' finished with zero exit code
    Restoring finished (verify backup restore log messages in /var/lib/rear/restore/recover.backup.577.restore.log)
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
    Exiting rear recover (PID 577) and its descendant processes ...
    Running exit tasks

