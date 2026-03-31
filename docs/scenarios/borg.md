# External backup using BorgBackup

[BorgBackup](https://www.borgbackup.org/) (short: Borg) is a deduplicating backup program with optional compression and authenticated encryption. Borg is highly efficient: only the data that has actually changed since the last backup is stored, making incremental backups fast and space-efficient. Borg supports local storage as well as remote repositories over SSH.

Currently there is no native `BACKUP=BORG` workflow in ReaR. You can [sponsor](https://relax-and-recover.org/support/sponsors) us to create one.

However, the `BACKUP=EXTERNAL` workflow can be used to drive Borg backups and restores through ReaR. Be aware that this is not officially supported by the ReaR maintainers. It is a best-effort integration using ReaR's generic external backup hook. No complaints, please, if something does not work as expected.

## Install BorgBackup

On RedHat-alike OSes you first need to install the EPEL repository:

    # dnf install epel-release

Then install Borg:

    # dnf install borgbackup

On Debian/Ubuntu systems:

    # apt install borgbackup

For other installation methods see the [BorgBackup installation page](https://borgbackup.readthedocs.io/en/stable/installation.html).

## Prepare a Borg repository

Borg stores backups in a *repository*, which must be initialised once before use. We use the `repokey` encryption mode so that the passphrase is stored alongside the repository key (suitable for home-lab and internal network scenarios). For production use, consider `repokey-blake2` or `keyfile` modes with a securely stored key.

    # borg init --encryption=repokey root@192.168.122.1:/apps/export/borg-backup
    Enter new passphrase: borgpass
    Enter same passphrase again: borgpass
    Do you want your passphrase to be displayed for verification? [yN]: N

!!! note
    Use a strong passphrase in production environments. The example above uses a weak passphrase for illustration purposes only.

To avoid entering the passphrase interactively every time Borg is called, store it in a dedicated file with restricted permissions:

    # echo "borgpass" > /etc/borg-passphrase
    # chmod 0400 /etc/borg-passphrase

## Excluding files and directories from the backup

Create an exclude-patterns file to prevent unnecessary or problematic paths from being backed up:

    # cat /etc/borg_exclude_patterns
    /proc
    /sys
    /dev
    /run
    /media
    /mnt
    /tmp
    /var/tmp

## Configuring ReaR

Make sure the `rear` package is installed. Create `/etc/rear/borg.conf` (or add the settings to `/etc/rear/local.conf`):

    # cat /etc/rear/borg.conf
    # This file etc/rear/borg.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).

    BACKUP=EXTERNAL
    OUTPUT=ISO
    OUTPUT_URL=nfs://192.168.122.1/apps/export/RBME

    COPY_AS_IS+=( '/etc/borg_exclude_patterns' '/etc/borg-passphrase' '/root/.ssh/' )
    SSH_FILES="yes"
    SSH_UNPROTECTED_PRIVATE_KEYS=true

    REQUIRED_PROGS+=( 'borg' )
    EXTERNAL_BACKUP="borg create --stats --compression lz4 --exclude-from /etc/borg_exclude_patterns root@192.168.122.1:/apps/export/borg-backup::'{hostname}-{now}' / /boot"
    EXTERNAL_RESTORE="borg extract root@192.168.122.1:/apps/export/borg-backup::'{hostname}-latest' --target /mnt/local/"

    # Use the same IP address(es) of this system in the rescue OS
    USE_STATIC_NETWORKING="y"

    # To be able to log in via SSH
    SSH_ROOT_PASSWORD="relax"

    # Limit rescue image size (no firmware, only loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )

    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

!!! note
    The `BORG_PASSPHRASE` environment variable needs to be available when `EXTERNAL_RESTORE` runs inside the rescue system. The approach used here relies on `/etc/borg-passphrase` being copied into the initramfs via `COPY_AS_IS` and passed to `borg` with `--passphrase-file`. Adjust the `EXTERNAL_BACKUP` and `EXTERNAL_RESTORE` commands to use `--passphrase-file /etc/borg-passphrase` if you prefer to avoid exporting the passphrase in the environment.

Update the commands to pass the passphrase file explicitly:

    EXTERNAL_BACKUP="borg create --stats --compression lz4 --exclude-from /etc/borg_exclude_patterns --passphrase-file /etc/borg-passphrase root@192.168.122.1:/apps/export/borg-backup::'{hostname}-{now}' / /boot"
    EXTERNAL_RESTORE="borg extract --passphrase-file /etc/borg-passphrase root@192.168.122.1:/apps/export/borg-backup::'{hostname}-latest' --target /mnt/local/"

## Running ReaR mkbackup

To create a ReaR rescue image and a full Borg backup in one step:

    [root@alma rear]# rear -v -C borg mkbackup
    Relax-and-Recover 2.7 / Git
    Running rear mkbackup (PID 12345)
    Using log file: /var/log/rear/rear-alma.log
    Sourcing additional configuration file '/etc/rear/borg.conf'
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
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (61234567 bytes) in 10 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-alma.iso (76M)
    Copying resulting files to nfs location
    Saving /var/log/rear/rear-alma.log as rear-alma.log to nfs location
    Running external backup command
    ------------------------------------------------------------------------------
    Archive name: alma-2025-11-20T15:11:54
    Archive fingerprint: a1b2c3d4e5f6...
    Time (start): Thu, 2025-11-20 15:11:54
    Time (end):   Thu, 2025-11-20 15:14:22
    Duration: 2 minutes 28 seconds
    Number of files: 142543
    Utilization of max. archive size: 0%
    ------------------------------------------------------------------------------
                           Original size      Compressed size    Deduplicated size
    This archive:                2.91 GB            949.58 MB            821.34 MB
    All archives:                2.91 GB            949.58 MB            821.34 MB
    ------------------------------------------------------------------------------
    Finished external backup command
    Exiting rear mkbackup (PID 12345) and its descendant processes ...
    Running exit tasks

## Recovering using ReaR and BorgBackup

Boot from the ISO image and run:

    RESCUE alma:~ # rear -v -C borg recover
    Relax-and-Recover 2.7 / Git
    Running rear recover (PID 576)
    Using log file: /var/log/rear/rear-alma.log
    Sourcing additional configuration file '/etc/rear/borg.conf'
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

* [BorgBackup home page](https://www.borgbackup.org/)

* [BorgBackup GitHub repository](https://github.com/borgbackup/borg)

* [BorgBackup Documentation](https://borgbackup.readthedocs.io/en/stable/)
