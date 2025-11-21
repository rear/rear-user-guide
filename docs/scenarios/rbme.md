# Rsync Backup Made Easy (RBME)

RBME was created by [Schlomo Schapiro](https://schlomo.schapiro.org/) in 2006 to have a simple backup using rsync per host and per day classified on the backup server.

ReaR 2.6 until 2.9 can only perform a recovery using RBME! Therefore, making backup with RBME needs to be done outside of ReaR.

However, we made a quick update to ReaR (v3.0 which is not released yet) to make a RBME backup via a `rear -v mkbackup` run.

## Install RBME package

The rbme package is not available anywhere, therefore, you have to generate it yourself by cloning [Gratien's rbme clone from Schlomo](https://github.com/gdha/rbme) if you want to create a RMP package.

The installation of the rpm or deb package has to be done as root via the usual commands. As reminder, `rbme` relies on `procmail`, so have this installed if not present.

## Configuring RBME

RBME comes with a `/etc/rbme.conf` configuration file. All details are nicely explained in this configuration file.

However, it is important to set the `BACKUP_PATH` variable correct!

    # Where to create the backups in.
    # Strongly recommended to be a separate filesystem !
    BACKUP_PATH=/backup

Be aware, that RBME backup workflow will generate another configuration file which will overrule the main setting of `BACKUP_PATH`:

    /etc/rbme.local.conf - path will be changed each time you run `rear mkbackup`
    BACKUP_PATH=/var/tmp/rear.GfkC5WobMbH7DcV/outputfs

If you want to receive a mail report make sure that `postfix` is installed and configure also in `/etc/rbme.conf`:

    # send result per email, separate multiple addresses by spaces
    MAILTO=root

Before making the first backup with RBME we could create an exclude list to avoid backing up some file systems, e.g.:

    # cat /etc/backup-excludes.lst 
    /apps
    /VMs

It is not required to add system in-memory file systems like `/proc`, `/sys`, `/tmp`, `/var/tmp` or `/run`


## Configuring ReaR for using RBME

The following `/etc/rear/local.conf` file was used to make a backup with RBME via ReaR:

    # cat /etc/rear/local.conf 
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    #
    #### Rsync Backup Made Easy ####
    ################################
    # RBME backup: Finished in 8131 seconds (135 min) -for 2.9 Gb data
    BACKUP=RBME
    BACKUP_URL=nfs://192.168.122.1/apps/export/RBME
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    SSH_ROOT_PASSWORD="relax"
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    # The difference in size of the iso image is 800Mb with and 80Mb without.
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

## Running ReaR/RBME

Now to make a ReaR image and a full backup of your system with RBME just run:

    # rear -v mkbackup
    ....
    Make a backup via RBME

Be aware, this may take a very long time to finish the first time you run RBME (more than 1 hour).

You could also run during the day `rear mkbackuponly` to just execute `rbme` without creating an iso image. This will take only a few seconds now.

For example, on our backup server we see the following inside the archive directory:

    dr-xr-xr-x. 18 root root      4096 Nov  6 10:35 2025-11-07
    dr-xr-xr-x. 18 root root      4096 Nov  6 10:35 2025-11-13
    dr-xr-xr-x. 16 root root      4096 Nov  6 10:35 2025-11-17
    dr-xr-xr-x. 14 root root       190 Nov  6 10:35 2025-11-18
    -rw-------.  1 root root       202 Nov 18 15:58 README
    -rw-r--r--.  1 qemu qemu  69658624 Nov 18 15:58 rear-alma.iso
    -rw-------.  1 root root    127954 Nov 18 15:58 rear-alma.log
    -rw-r--r--.  1 root root 866234368 Nov 13 15:35 rear-alma-rbme.iso
    -rw-------.  1 root root       267 Nov 18 15:58 VERSION

## Recover the system with RBME

Boot the iso image and once you have a prompt run the command: `rear -v recover`

    RESCUE alma:~ # rear -v recover
    Relax-and-Recover 2.6 / 2020-06-17
    Running rear recover (PID 575)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow recover within the ReaR rescue/recovery system
    Starting required daemons for NFS: RPC portmapper (portmap or rpcbind) and rpc.statd if available.
    Started RPC portmapper 'rpcbind'.
    RPC portmapper 'rpcbind' available.
    Starting rpc.statd failed.
    RPC status rpc.statd unavailable (you may have to mount NFS without locking 'nolock').
    Select a backup to restore.
    1) 2025-11-19
    2) 2025-11-20
    3) Abort
    #? 2
    Backup 2025-11-20 chosen.
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
    Restoring from backup 2025-11-20.
    Preparing restore operation
    Restored 461 MiB [avg 42917 KiB/sec]
    Restored 991 MiB [avg 48329 KiB/sec]
    Restored 1440 MiB [avg 47580 KiB/sec]
    Restored 1598 MiB [avg 39912 KiB/sec]
    Restored 1976 MiB [avg 39682 KiB/sec]
    OK
    Restored 1976 MiB in 61 seconds [avg 33176 KiB/sec]
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
    Exiting rear recover (PID 575) and its descendant processes ...
    Running exit tasks

Rebooted the recovered system, and it came up fine. No issues encountered on the system.

### References

* [GitHub rbme project](https://github.com/schlomo/rbme)
