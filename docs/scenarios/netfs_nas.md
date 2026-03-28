# Internal Backup with GNU tar to NAS (NFS) Share

We use the `BACKUP=NETFS` method with GNU tar to create a full archive of our system on an NFS share (NAS device). This is a real-world example that includes several advanced configuration options.

We use `/oem` as the temporary directory for building the ISO image instead of the default `/tmp` — see `export TMPDIR=/oem`.

All file systems and volume groups are included in the OS archive so that the recovery process can restore everything. We commented out the `ONLY_INCLUDE_VG` variable setting and explicitly set `AUTOEXCLUDE_DISKS=no` to achieve this.

To use zstandard (zstd) as the compression algorithm instead of the default gzip, we added the `zstd` executable to the `COPY_AS_IS` variable array and defined the `BACKUP_PROG_COMPRESS_OPTIONS` and `BACKUP_PROG_COMPRESS_SUFFIX` variables.

```bash
export TMPDIR=/oem
# ONLY_INCLUDE_VG=( "vg00" )
BACKUP=NETFS
NETFS_PREFIX=image
NETFS_KEEP_OLD_BACKUP_COPY=yes
CLONE_USERS=( "${CLONE_USERS[@]}" oracle )
CLONE_GROUPS=( "${CLONE_GROUPS[@]}" dba )
TIMESYNC=CHRONY
TIMESYNC_SOURCE=10.255.255.10
SSH_ROOT_PASSWORD="rear"
COPY_AS_IS=( "${COPY_AS_IS[@]}" /etc/oratab clear $(which zstd) )
POST_RECOVERY_SCRIPT=/mnt/local/u02/restore_oracle_u02_database_directory.sh
AUTOEXCLUDE_DISKS=no
BACKUP_PROG_EXCLUDE=( ${BACKUP_PROG_EXCLUDE[@]} '/u02/ora*' '/u02/recoveryarea01' '/u01/app/oracle/admin/JHHD0173/diag/rdbms/*' '/u01/app/oracle/admin/JHHD0173/RMAN/logs/*' '/app/scm-dvl/SCM-Releases/*' )
BACKUP_OPTIONS="nfsvers=4,nolock"
BACKUP_URL=nfs://mynas.example.com/rear_backups/linux_images/my-server.example.com
PRE_BACKUP_SCRIPT=( 'rm -rf /tmp/cfg2html*' )
USE_CFG2HTML=no
FIRMWARE_FILES=( 'no' )
BACKUP_PROG_COMPRESS_OPTIONS=( '--use-compress-program=zstd' )
BACKUP_PROG_COMPRESS_SUFFIX=".zst"
```

Key settings explained:

- `BACKUP=NETFS`: Uses the NETFS method, which mounts the NFS share and stores the backup archive directly on it.
- `NETFS_PREFIX=image`: The sub-directory name created under the NFS share for storing the backup files.
- `NETFS_KEEP_OLD_BACKUP_COPY=yes`: Keeps the previous backup copy before creating a new one, providing a one-generation rollback.
- `BACKUP_OPTIONS="nfsvers=4,nolock"`: NFS mount options — NFS version 4 without file locking.
- `BACKUP_URL`: The NFS URL pointing to the NAS share where the rescue ISO and backup archive are stored.
- `BACKUP_PROG_COMPRESS_OPTIONS` and `BACKUP_PROG_COMPRESS_SUFFIX`: Override the default gzip compression in favour of zstd, which typically offers better speed and compression ratio.
- `AUTOEXCLUDE_DISKS=no`: Disables the automatic exclusion of disks that are not used, so all disks are included in the layout.
- `FIRMWARE_FILES=( 'no' )`: Skips copying firmware files into the rescue image, reducing its size.

## Running rear mkbackup

To create the ReaR rescue ISO image together with a full tar backup of the system, run:

    [root@myserver ~]# rear -v mkbackup
    Relax-and-Recover 2.9 / 2024-02-29
    Running rear mkbackup (PID 5842)
    Using log file: /var/log/rear/rear-myserver.log
    Running workflow mkbackup on the normal/original system
    Using backup archive '/var/tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image/backup.tar.zst'
    Using autodetected kernel '/boot/vmlinuz-5.14.0-570.58.1.el9_6.x86_64' as kernel in the recovery system
    Creating disk layout
    Overwriting existing disk layout file /var/lib/rear/layout/disklayout.conf
    GRUB found in first bytes on /dev/sda and GRUB 2 is installed, using GRUB2 as a guessed bootloader for 'rear recover'
    Verifying that the entries in /var/lib/rear/layout/disklayout.conf are correct ...
    Creating recovery system root filesystem skeleton layout
    Copying logfile /var/log/rear/rear-myserver.log into initramfs as '/tmp/rear-myserver-partial-2024-03-15T09:12:34+01:00.log'
    Copying files and directories
    Copying binaries and libraries
    Omit copying files in /lib*/firmware/ (FIRMWARE_FILES='no')
    Testing that the recovery system in /var/tmp/rear.tKwLmNpBr8XyZ4Q/rootfs contains a usable system
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (57892416 bytes) in 11 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-myserver.iso (72M)
    Copying resulting files to nfs location
    Saving /var/log/rear/rear-myserver.log as rear-myserver.log to nfs location
    Copying result files '/var/lib/rear/output/rear-myserver.iso /var/tmp/rear.tKwLmNpBr8XyZ4Q/tmp/VERSION /var/tmp/rear.tKwLmNpBr8XyZ4Q/tmp/README /var/tmp/rear.tKwLmNpBr8XyZ4Q/tmp/rear-myserver.log' to /var/tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image at nfs location
    Making backup (using backup method NETFS)
    Creating tar archive '/var/tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image/backup.tar.zst'
    Preparing archive operation
    Archived 512 MiB [avg 89201 KiB/sec]
    Archived 1024 MiB [avg 91345 KiB/sec]
    Archived 1536 MiB [avg 88712 KiB/sec]
    Archived 2048 MiB [avg 87934 KiB/sec]
    Archived 2560 MiB [avg 86120 KiB/sec]
    OK
    Archived 2601 MiB in 30 seconds [avg 88678 KiB/sec]
    Exiting rear mkbackup (PID 5842) and its descendant processes ...
    Running exit tasks

## The NFS server contains the archive backup

On the NAS the backup directory under `NETFS_PREFIX=image` will contain:

    [root@mynas rear_backups]# ll linux_images/my-server.example.com/image/
    total 3145780
    -rw-------.  1 root root 3145728000 Mar 15 09:13 backup.tar.zst
    -rw-------.  1 root root     156234 Mar 15 09:13 backup.log
    -rw-------.  1 root root        202 Mar 15 09:12 README
    -rw-------.  1 root root   75497472 Mar 15 09:12 rear-myserver.iso
    -rw-------.  1 root root     143521 Mar 15 09:12 rear-myserver.log
    -rw-------.  1 root root        268 Mar 15 09:12 VERSION

When `NETFS_KEEP_OLD_BACKUP_COPY=yes` is set, the previous backup is moved to a sub-directory called `rear.old` before the new backup is written, giving you one generation of rollback:

    [root@mynas rear_backups]# ll linux_images/my-server.example.com/image/rear.old/
    total 3012600
    -rw-------.  1 root root 3012598784 Mar 14 09:08 backup.tar.zst
    -rw-------.  1 root root     148721 Mar 14 09:08 backup.log

## Recovering with NETFS method and GNU tar

Boot from the rescue ISO image and run `rear -v recover`:

    RESCUE myserver:~ # rear -v recover
    Relax-and-Recover 2.9 / 2024-02-29
    Running rear recover (PID 601)
    Using log file: /var/log/rear/rear-myserver.log
    Running workflow recover within the ReaR rescue/recovery system
    Starting required daemons for NFS: RPC portmapper (portmap or rpcbind) and rpc.statd if available.
    Started RPC portmapper 'rpcbind'.
    RPC portmapper 'rpcbind' available.
    Started rpc.statd.
    RPC status rpc.statd available.
    Started rpc.idmapd.
    Using backup archive '/tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image/backup.tar.zst'
    Calculating backup archive size
    Backup archive size is 3.0G     /tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image/backup.tar.zst
    Comparing disks
    Device sda has expected (same) size 107374182400 bytes (will be used for 'recover')
    Disk configuration looks identical
    Proceed with 'recover' (yes) otherwise manual disk layout configuration is enforced
    (default 'yes' timeout 30 seconds)
    yes
    User confirmed to proceed with 'recover'
    Start system layout restoration.
    Disk '/dev/sda': creating 'gpt' partition table
    Disk '/dev/sda': creating partition number 1 with name 'primary'
    Disk '/dev/sda': creating partition number 2 with name 'primary'
    Creating LVM PV /dev/sda2
    Restoring LVM VG 'vg00'
    Sleeping 3 seconds to let udev or systemd-udevd create their devices...
    Creating filesystem of type xfs with mount point / on /dev/mapper/vg00-lv_root.
    Mounting filesystem /
    Creating filesystem of type xfs with mount point /boot on /dev/sda1.
    Mounting filesystem /boot
    Creating filesystem of type xfs with mount point /u01 on /dev/mapper/vg00-lv_u01.
    Mounting filesystem /u01
    Creating swap on /dev/mapper/vg00-lv_swap
    Disk layout created.
    Restoring from '/tmp/rear.tKwLmNpBr8XyZ4Q/outputfs/image/backup.tar.zst' (restore log in /var/lib/rear/restore/recover.backup.601.restore.log) ...
    Backup restore program 'tar' started in subshell (PID=2048)
    Restoring for 10 seconds...
    Restoring for 20 seconds...
    Restoring for 30 seconds...
    OK
    Backup restore program 'tar' finished with zero exit code
    Restoring finished (verify backup restore log messages in /var/lib/rear/restore/recover.backup.601.restore.log)
    Running POST_RECOVERY_SCRIPT '/mnt/local/u02/restore_oracle_u02_database_directory.sh'
    Created SELinux /mnt/local/.autorelabel file : after reboot SELinux will relabel all files
    Recreating directories (with permissions) from /var/lib/rear/recovery/directories_permissions_owner_group
    Migrating disk-by-id mappings in certain restored files in /mnt/local to current disk-by-id mappings ...
    Running dracut...
    Updated initrd with new drivers for kernel 5.14.0-570.58.1.el9_6.x86_64.
    Installing GRUB2 boot loader...
    Determining where to install GRUB2 (no GRUB2_INSTALL_DEVICES specified)
    Found possible boot disk /dev/sda - installing GRUB2 there
    Finished 'recover'. The target system is mounted at '/mnt/local'.
    Exiting rear recover (PID 601) and its descendant processes ...
    Running exit tasks

After the recovery completes, reboot the system. If SELinux is enabled, a relabeling pass will run automatically on the first boot.
