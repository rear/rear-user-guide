# External backup using BACKUP=DUPLICITY method

Duplicity is a software suite that provides encrypted, digitally signed, versioned, local or remote backup of files requiring little of the remote server.

## Installing duplicity

Duplicity is available on (almost) all major Linux distributions and can be simply installed via the distribution installer software, e.g. on RHEL-based systems duplicity is part of the EPEL repository and can be installed as:

    # yum install -y duplicity
    ======================================================================================================================================================================
     Package                                               Architecture                            Version                                         Repository                                  Size
    ======================================================================================================================================================================
    Installing:
     duplicity                                             x86_64                                  0.8.23-2.el9                                    epel                                       607 k
    Installing dependencies:
     librsync                                              x86_64                                  2.3.4-1.el9                                     epel                                        57 k
     libsodium                                             x86_64                                  1.0.18-8.el9                                    epel                                       161 k
     python3-bcrypt                                        x86_64                                  3.2.2-1.el9                                     epel                                        43 k
     python3-botocore                                      noarch                                  1.31.62-2.el9                                   epel                                       6.1 M
     python3-cffi                                          x86_64                                  1.14.5-5.el9                                    baseos                                     241 k
     python3-cryptography                                  x86_64                                  36.0.1-5.el9_6                                  baseos                                     1.2 M
     python3-fasteners                                     noarch                                  0.19-1.el9                                      epel                                        38 k
     python3-future                                        noarch                                  0.18.3-3.el9                                    epel                                       731 k
     python3-idna                                          noarch                                  2.10-7.el9_4.1                                  baseos                                      96 k
     python3-jmespath                                      noarch                                  0.9.4-11.el9                                    appstream                                   45 k
     python3-lockfile                                      noarch                                  1:0.12.2-8.el9                                  epel                                        30 k
     python3-pexpect                                       noarch                                  4.8.0-7.el9                                     baseos                                     134 k
     python3-ply                                           noarch                                  3.11-14.el9                                     baseos                                     103 k
     python3-ptyprocess                                    noarch                                  0.6.0-12.el9                                    baseos                                      29 k
     python3-pycparser                                     noarch                                  2.20-6.el9                                      baseos                                     124 k
     python3-pynacl                                        x86_64                                  1.4.0-6.el9                                     epel                                       106 k
     python3-pysocks                                       noarch                                  1.7.1-12.el9                                    baseos                                      34 k
     python3-s3transfer                                    noarch                                  0.7.0-1.el9                                     epel                                       113 k
     python3-setuptools                                    noarch                                  53.0.0-15.el9                                   baseos                                     831 k
     python3-urllib3                                       noarch                                  1.26.5-6.el9                                    baseos                                     187 k
    Installing weak dependencies:
     ncftp                                                 x86_64                                  2:3.2.5-23.el9                                  epel                                       382 k
     python3-boto3                                         noarch                                  1.28.62-1.el9                                   epel                                       164 k
     python3-paramiko                                      noarch                                  2.12.0-3.el9                                    epel                                       293 k
     python3-pyasn1                                        noarch                                  0.4.8-6.el9                                     appstream                                  132 k
    
    Transaction Summary
    ======================================================================================================================================================================
    Install  25 Packages
    
    Total download size: 12 M
    Installed size: 108 M

Be aware, as duplicity is written in the Python language we also need the python packages to be installed.

One of the key features of duplicity is that it uses under the good GnuPG to encrypt/decrypt the backups, therefore, make sure gpg is alos available on your system.

## Generate GnuPG keys

If you want to encrypt/decrypt the duplicity backups using gpg then it is required to create a private/public gpg key. Therefore, do the following (example only):

    # gpg --list-keys
    gpg: directory '/root/.gnupg' created
    gpg: keybox '/root/.gnupg/pubring.kbx' created
    gpg: /root/.gnupg/trustdb.gpg: trustdb created
    
    
    # gpg --full-gen-key
    gpg (GnuPG) 2.3.3; Copyright (C) 2021 Free Software Foundation, Inc.
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    
    Please select what kind of key you want:
       (1) RSA and RSA (default)
       (2) DSA and Elgamal
       (3) DSA (sign only)
       (4) RSA (sign only)
      (14) Existing key from card
    Your selection? 1
    RSA keys may be between 1024 and 4096 bits long.
    What keysize do you want? (3072) 
    Requested keysize is 3072 bits
    Please specify how long the key should be valid.
             0 = key does not expire
          <n>  = key expires in n days
          <n>w = key expires in n weeks
          <n>m = key expires in n months
          <n>y = key expires in n years
    Key is valid for? (0) 
    Key does not expire at all
    Is this correct? (y/N) y
    
    GnuPG needs to construct a user ID to identify your key.
    
    Real name: root@alma
    Email address: root@localhost
    Comment: 
    You selected this USER-ID:
        "root@alma <root@localhost>"
    
    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
    We need to generate a lot of random bytes. It is a good idea to perform
    some other action (type on the keyboard, move the mouse, utilize the
    disks) during the prime generation; this gives the random number
    generator a better chance to gain enough entropy.
    We need to generate a lot of random bytes. It is a good idea to perform
    some other action (type on the keyboard, move the mouse, utilize the
    disks) during the prime generation; this gives the random number
    generator a better chance to gain enough entropy.
    gpg: key 18A6F5D8C7945A62 marked as ultimately trusted
    gpg: directory '/root/.gnupg/openpgp-revocs.d' created
    gpg: revocation certificate stored as '/root/.gnupg/openpgp-revocs.d/72B27A3F5F5D09347B74D9ED18A6F5D8C7945A62.rev'
    public and secret key created and signed.
    
    pub   rsa3072 2025-11-28 [SC]
          72B27A3F5F5D09347B74D9ED18A6F5D8C7945A62
    uid                      root@alma <root@localhost>
    sub   rsa3072 2025-11-28 [E]

In the last step of gpg key creation a passphrase needs to be added. It is important not to loose this passphrase! In our example we choose *r00t@alma* as passphrase.

## Configure ReaR to use duplicity

It is important to know that the /root/.gnupg/ directory will also be copied to the ReaR rescue image!

Below is the local.conf file we used in our test environment which is a good guideline for our end-users to get started with ReaR/Duplicity.

Also, be aware to avoid that secrets will be logged use the `{ SSH_ROOT_PASSWORD="relax" ; } 2>>/dev/$SECRET_OUTPUT_DEV` trick.

    # cat /etc/rear/local.conf  
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    #
    ################################
    BACKUP=DUPLICITY
    DUPLICITY_USER=root
    DUPLICITY_HOST=192.168.122.1
    DUPLICITY_PROTO="rsync"
    DUPLICITY_PATH=/apps/export/ReaR
    BACKUP_DUPLICITY_URL="${DUPLICITY_PROTO}://${DUPLICITY_USER}@${DUPLICITY_HOST}/${DUPLICITY_PATH}"
    # Duplicity options
    BACKUP_DUPLICITY_MAX_SETS_KEEP_FULL="3"
    BACKUP_DUPLICITY_MAX_TIME="1Y"
    
    # To protect seeing the passphrase and key:
    { BACKUP_DUPLICITY_GPG_ENC_KEY="72B27A3F5F5D09347B74D9ED18A6F5D8C7945A62" ; } 2>>/dev/$SECRET_OUTPUT_DEV
    { BACKUP_DUPLICITY_GPG_ENC_PASSPHRASE="r00t@alma" ; } 2>>/dev/$SECRET_OUTPUT_DEV
    
    # To ask the passphrase on restore, set the following variable to true:
    BACKUP_DUPLICITY_ASK_PASSPHRASE="true"
    
    BACKUP_DUPLICITY_TEMP_RAMDISK="true"
    BACKUP_DUPLICITY_EXCLUDE=( '/proc' '/sys' '/run' '/var/lib/ntp/proc' "$HOME/.cache" '/tmp' '/var/tmp' '/app' '/var/app' )
    # Keep BACKUP_DUPLICITY_RESTORE_TIME in comment, and only uncomment before recovery (if a PIT recovery is required)
    #BACKUP_DUPLICITY_RESTORE_TIME="--restore-time=1D"
    
    OUTPUT=ISO
    OUTPUT_URL="${DUPLICITY_PROTO}://${DUPLICITY_USER}@${DUPLICITY_HOST}/${DUPLICITY_PATH}"
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    { SSH_ROOT_PASSWORD="relax" ; } 2>>/dev/$SECRET_OUTPUT_DEV
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

## Running rear -v mkbackup

Well, now it is time to create a ReaR rescue image with a full (or incremental) backup with the help of `duplicity`. For eaxmple:

    # rear -v mkbackup
    Relax-and-Recover 2.9-git.5719.2cb54575.gdhaduplicity.changed / 2025-12-11
    Running rear mkbackup (PID 1695 date 2026-01-05 17:56:18)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow mkbackup on the normal/original system
    Using /bin/python as Python interpreter and including all site/dist packages
    Using autodetected kernel '/boot/vmlinuz-5.14.0-570.58.1.el9_6.x86_64' as kernel in the recovery system
    Creating disk layout
    Overwriting existing disk layout file /var/lib/rear/layout/disklayout.conf
    GRUB found in first bytes on /dev/vda and GRUB 2 is installed, using GRUB2 as a guessed bootloader for 'rear recover'
    Verifying that the entries in /var/lib/rear/layout/disklayout.conf are correct
    Created disk layout (check the results in /var/lib/rear/layout/disklayout.conf)
    Creating recovery system root filesystem skeleton layout
    Skipping network interface 'lo': not bound to any physical interface.
    Copying logfile /var/log/rear/rear-alma.log into initramfs as '/tmp/rear-alma-partial-2026-01-05T17:56:24+01:00.log'
    Copying files and directories
    Copying binaries and libraries
    Failed to copy '/usr/lib/cruft'
    Copying only currently loaded kernel modules (MODULES contains 'loaded_modules') and those in MODULES_LOAD
    Omit copying files in /lib*/firmware/ (FIRMWARE_FILES='no')
    Testing that the ReaR recovery system in '/var/tmp/rear.ZevSLzPL2xIlEBG/rootfs' contains a usable system
    usr/lib64/python3.9/site-packages/hawkey/test/_hawkey_test.so requires libraries where 'ldd' shows 'not found'
    usr/lib64/python3.9/site-packages/hawkey/test/_hawkey_test.so requires _hawkey.so which exists as usr/lib64/python3.9/site-packages/hawkey/_hawkey.so
    usr/lib64/systemd/libsystemd-core-252.so requires libraries where 'ldd' shows 'not found'
    usr/lib64/systemd/libsystemd-core-252.so requires libsystemd-shared-252.so which exists as usr/lib64/systemd/libsystemd-shared-252.so
    Creating recovery/rescue system initramfs/initrd initrd.cgz with gzip default compression
    Created initrd.cgz with gzip default compression (92 MiB) in 14 seconds
    Making ISO image
    Wrote ISO image: /var/lib/rear/output/rear-alma.iso (110M)
    Copying resulting files to rsync location
    Saving /var/log/rear/rear-alma.log as rear-alma.log to rsync location
    Copying result files '/var/lib/rear/output/rear-alma.iso /var/tmp/rear.ZevSLzPL2xIlEBG/tmp/VERSION /var/tmp/rear.ZevSLzPL2xIlEBG/tmp/README /var/tmp/rear.ZevSLzPL2xIlEBG/tmp/rear-alma.log' to rsync location
    Duplicity passphrase must be provided interactively on restore (BACKUP_DUPLICITY_ASK_PASSPHRASE is set)
    Creating duplicity archives on 'rsync://root@192.168.122.1//apps/export/ReaR'
    EXCLUDES =  --exclude /proc --exclude /sys --exclude /run --exclude /var/lib/ntp/proc --exclude /root/.cache --exclude /tmp --exclude /var/tmp --exclude /app --exclude /var/app
    Checking backup-path at server ...
    Removing the old Backups from the Server with CMD:
        /bin/duplicity remove-all-inc-of-but-n-full --name rear-backup --force 3 -v5 rsync://root@192.168.122.1//apps/export/ReaR/alma
    Removing the old Backups from the Server with CMD:
        /bin/duplicity remove-older-than --name rear-backup --force 1Y -v5 rsync://root@192.168.122.1//apps/export/ReaR/alma
    Running CMD: /bin/duplicity -v5 --name rear-backup   <GPG_KEY>  --exclude /proc --exclude /sys --exclude /run --exclude /var/lib/ntp/proc --exclude /root/.cache --exclude /tmp --exclude /var/tmp --exclude /app --exclude /var/app / rsync://root@192.168.122.1//apps/export/ReaR/alma >> /var/tmp/rear.ZevSLzPL2xIlEBG/tmp/backup.log
    --------------[ Backup Statistics ]--------------
    StartTime 1767632242.98 (Mon Jan  5 17:57:22 2026)
    EndTime 1767632257.14 (Mon Jan  5 17:57:37 2026)
    ElapsedTime 14.17 (14.17 seconds)
    SourceFiles 47785
    SourceFileSize 2340805120 (2.18 GB)
    NewFiles 613
    NewFileSize 21343993 (20.4 MB)
    DeletedFiles 4
    ChangedFiles 71
    ChangedFileSize 244368381 (233 MB)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 688
    RawDeltaSize 157801740 (150 MB)
    TotalDestinationSizeChange 134573979 (128 MB)
    Errors 0
    -------------------------------------------------
    Exiting rear mkbackup (PID 1695) and its descendant processes ...
    Running exit tasks

## Recover your system with ReaR (and duplicity)

    # rear -v recover
    Relax-and-Recover 2.9-git.5719.2cb54575.gdhaduplicity.changed / 2025-12-11
    Running rear recover (PID 579 date 2026-01-06 14:51:44)
    Using log file: /var/log/rear/rear-alma.log
    Running workflow recover within the ReaR rescue/recovery system
    File system /tmp not present - mounting it via tmpfs
    Comparing disks
    Device vda has expected (same) size 8589934592 bytes (will be used for 'recover')
    Disk configuration looks identical
    Proceed with 'recover' (yes) otherwise manual disk layout configuration is enforced
    (default 'yes' timeout 30 seconds)
    yes
    User confirmed to proceed with 'recover'
    Disks to be completely overwritten and recreated by /var/lib/rear/layout/diskrestore.sh:
      /dev/vda 
    Determining disks to be wiped ...
    Disks to be wiped: /dev/vda 
    1) Confirm disks to be wiped and continue 'rear recover'
    2) Skip wiping disks and continue 'rear recover'
    3) Use Relax-and-Recover shell and return back to here
    4) Abort 'rear recover'
    (default '1' timeout 30 seconds)
    1
    User confirmed disks to be wiped
    Wiping child devices of /dev/vda in reverse ordering: /dev/vda2 /dev/vda1 /dev/vda 
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
    ========================================================================
    Restoring backup with duplicity from 'rsync://root@192.168.122.1//apps/export/ReaR'
    ========================================================================
    Enter 'Passphrase' for the restore [300 secs]: **********
    Logging to /var/tmp/rear.cNj5nZ9vY0Bmtt0/tmp/duplicity-restore.log
    with CMD: /usr/sbin/duplicity -v 5  <GPG_KEY>  --force --tempdir=/mnt/tmp rsync://root@192.168.122.1//apps/export/ReaR/alma/ /mnt/local
    Could not remove Temporary Directory for Duplicity: /mnt/tmp
    ========================================================================
    Restore completed in 125 seconds.
    ========================================================================
    Transferring Logfile /var/tmp/rear.cNj5nZ9vY0Bmtt0/tmp/duplicity-restore.log to /mnt/local/tmp/
    Created SELinux /mnt/local/.autorelabel file : after reboot SELinux will relabel all files
    Recreating directories (with permissions) from /var/lib/rear/recovery/directories_permissions_owner_group
    Checking if certain restored files are consistent with the recreated system
    Renamed LVM devices file /mnt/local//etc/lvm/devices/system.devices to /mnt/local//etc/lvm/devices/system.devices.rearbak
    to prevent LVM problems in the recovered system, verify that the file
    is correct after booting the recovered system and move it back, or
    regenerate it using vgimportdevices.
    Migrating disk-by-id mappings in certain restored files in /mnt/local to current disk-by-id mappings ...
    Migrating restored network configuration files according to the mapping files ...
    Running dracut...
    Updated initrd with new drivers for kernel 5.14.0-503.11.1.el9_5.x86_64.
    Running dracut...
    Updated initrd with new drivers for kernel 5.14.0-570.58.1.el9_6.x86_64.
    Installing GRUB2 boot loader...
    Determining where to install GRUB2 (no GRUB2_INSTALL_DEVICES specified)
    Found possible boot disk /dev/vda - installing GRUB2 there
    Finished 'recover'. The target system is mounted at '/mnt/local'.
    Exiting rear recover (PID 579) and its descendant processes ...
    Running exit tasks


## References

[1 duplicity main site](https://duplicity.us/)

[2 duplicity wikipedia page](https://en.wikipedia.org/wiki/Duplicity_(software))

[3 GnuPG options](https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration-Options.html#GPG-Configuration-Options)
