# Configuration

There are two important variables that influence Relax-and-Recover and the rescue image. Set **OUTPUT** to your preferred boot method and define **BACKUP** for your favorite **BACKUP** strategy.

Furthermore, the **BACKUP** scheme can be an internal one, meaning using `tar` or `rsync`, or an external one, meaning use a backup program of your choice, e.g. TSM, Legato, and so on.

<div align="right"><img src="../img/backup-internal-external.png" alt="An simple overview of BACKUP and OUTPUT"></div>

The configuration is performed by changing `/etc/rear/local.conf` or `/etc/rear/site.conf`.

In most cases only these two settings are required. More complex scenarios examples will be available in the [Scenarios](../scenarios/) chapter.


## Rescue media (OUTPUT)
The **OUTPUT** variable defines where the rescue image should be sent to.
Possible **OUTPUT** setting are:

* **OUTPUT=RAMDISK**: 
Copy the kernel and the initramfs containing the rescue system to a selected
location.

* **OUTPUT=ISO**:
Create a bootable ISO9660 image on disk as `rear-$(hostname).iso`

* **OUTPUT=PXE**:
Create on a remote PXE/NFS server the required files (such as configuration file, kernel and initrd image)

* **OUTPUT=OBDR**:
Create a bootable OBDR tape including the backup archive. Specify the OBDR tape device by using `TAPE_DEVICE`.

* **OUTPUT=USB**:
Create a bootable USB disk.

* **OUTPUT=RAWDISK**:
Create a bootable raw disk image on as `rear-$(hostname).raw.gz`. Supports UEFI boot if syslinux/EFI or Grub 2/EFI is installed. Supports Legacy BIOS boot if syslinux is installed. Supports UEFI/Legacy BIOS dual boot if syslinux _and_ one of the supported EFI bootloaders are installed.

### Using OUTPUT_URL with ISO, RAMDISK or RAWDISK output methods
When using **OUTPUT=ISO**, **OUTPUT=RAMDISK** or **OUTPUT=RAWDISK** you should provide the backup target location through the `OUTPUT_URL` variable. Possible `OUTPUT_URL` settings are:

* **OUTPUT_URL=file://**:
Write the ISO image to disk. The default is in _/var/lib/rear/output/_.

* **OUTPUT_URL=fish//**:
Write the ISO image using `lftp` and the FISH protocol.

* **OUTPUT_URL=ftp://**:
Write the ISO image using `lftp` and the FTP protocol.

* **OUTPUT_URL=ftps://**:
Write the ISO image using `lftp` and the FTPS protocol.

* **OUTPUT_URL=hftp://**:
Write the ISO image using `lftp` and the HFTP protocol.

* **OUTPUT_URL=http://**:
Write the ISO image using `lftp` and the HTTP (PUT) procotol.

* **OUTPUT_URL=https://**:
Write the ISO image using `lftp` and the HTTPS (PUT) protocol.

* **OUTPUT_URL=nfs://**:
Write the ISO image using _nfs_ and the NFS protocol.

* **OUTPUT_URL=sftp://**:
Write the ISO image using `lftp` and the secure FTP (SFTP) protocol.

* **OUTPUT_URL=rsync://**:
Write the ISO image using `rsync` and the RSYNC protocol.

* **OUTPUT_URL=sshfs://**:
Write the image using _sshfs_ and the SSH protocol.

* **OUTPUT_URL=null**:
Do not copy the ISO image from _/var/lib/rear/output/_ to a remote output location.
`OUTPUT_URL=null` is useful when another program (e.g. an _external_ backup program)
is used to save the ISO image from the local system to a remote place,
or with `BACKUP_URL=iso:///backup` when the backup is included in the ISO image
to avoid a (big) copy of the ISO image at a remote output location.
In the latter case the ISO image must be manually saved from the local system to a remote place.
`OUTPUT_URL=null` is only supported together with `BACKUP=NETFS`.

The default boot option of the created ISO is boothd / "boot from first harddisk". If you want to change this,
e.g. because you integrate REAR into some automation process, you can change the default using
_ISO_DEFAULT={manual,automatic,boothd}_


## Backup/Restore strategy (BACKUP)
The **BACKUP** setting defines our backup/restore strategy. The **BACKUP** can be handled via internal archive executable (`tar` or `rsync`) or by an external backup program (commercial or open source).

Possible **BACKUP** settings are:

* **BACKUP=TSM**:
Use IBM Tivoli Storage Manager programs

* **BACKUP=DP**:
Use Micro Focus Data Protector programs

* **BACKUP=FDRUPSTREAM**:
Use FDR/Upstream

* **BACKUP=NBU**:
Use Symantec NetBackup programs

* **BACKUP=NSR**:
Use EMC NetWorker (Legato)

* **BACKUP=BACULA**:
Use Bacula programs

* **BACKUP=BAREOS**:
Use Bareos fork of Bacula
!!! note
    _BAREOS_FILESET=Full_ : 
    Only if you have more than one fileset defined for your clients backup jobs, you need to specify which to use for restore)

* **BACKUP=GALAXY**:
Use CommVault Galaxy (5, probably 6)

* **BACKUP=GALAXY7**:
Use CommVault Galaxy (7 and probably newer)

* **BACKUP=GALAXY10**:
Use CommVault Galaxy 10 (or Simpana 10)

* **BACKUP=BORG**:
Use BorgBackup (short Borg) a deduplicating backup program to restore the data.

* **BACKUP=NETFS**:
Use Relax-and-Recover internal backup with tar or rsync (or similar).
When using `BACKUP=NETFS` and `BACKUP_PROG=tar` there is an option to select
`BACKUP_TYPE=incremental` or `BACKUP_TYPE=differential` to let ReaR make
incremental or differential backups until the next full backup day
e.g. via `FULLBACKUPDAY="Mon"` is reached or when the last full backup
is too old after FULLBACKUP_OUTDATED_DAYS has passed.
Incremental or differential backup is currently only known to work
with `BACKUP_URL=nfs://server/path`. Other `BACKUP_URL` schemes may work e.g.
`BACKUP_URL=usb:///dev/disk/by-label/REAR-000`

* **BACKUP=REQUESTRESTORE**:
No backup, just ask user to somehow restore the filesystems.

* **BACKUP=EXTERNAL**:
Use a custom strategy by providing backup and restore commands.

* **BACKUP=DUPLICITY**:
Use duplicity to manage backup (see http://duplicity.nongnu.org). Additionally if duply
(see http://duply.net) is also installed while generating the rescue images it is
part of the image.

* **BACKUP=RBME**:
Use Rsync Backup Made Easy (rbme) to restore the data.

* **BACKUP=RSYNC**:
Use rsync to foresee in backup and restore of your system disks.

* **BACKUP=BLOCKCLONE**:
Backup block devices using dd or ntfsclone

## Using NETFS as backup strategy (internal archive method)
When using **BACKUP=NETFS** you should provide the backup target location through the `BACKUP_URL` variable. Possible `BACKUP_URL` settings are:

* **BACKUP_URL=file://**:
To backup to local disk, use `BACKUP_URL=file:///directory/path/`

* **BACKUP_URL=nfs://**:
To backup to NFS disk, use `BACKUP_URL=nfs://nfs-server-name/share/path`

* **BACKUP_URL=tape://**:
To backup to tape device, use `BACKUP_URL=tape:///dev/nst0` or alternatively, simply define `TAPE_DEVICE=/dev/nst0`

* **BACKUP_URL=cifs://**:
To backup to a Samba share (CIFS), use `BACKUP_URL=cifs://cifs-server-name/share/path+. To provide credentials for
CIFS mounting use a _/etc/rear/cifs_ credentials file and define `BACKUP_OPTIONS="cred=/etc/rear/cifs"+ and pass along:

```bash
username=_username_
password=_secret password_
domain=_domain_
```

* **BACKUP_URL=sshfs://**:
To backup over the network with the help of sshfs. You need the fuse-sshfs package before you can use FUSE-Filesystem to access remote filesystems via SSH. An example of defining the `BACKUP_URL` could be:

```bash
BACKUP_URL=sshfs://root@server/export/archives
```

* **BACKUP_URL=usb://**:
To backup to USB storage device, use `BACKUP_URL=usb:///dev/disk/by-label/REAR-000` or use a real device node or a specific filesystem label. Alternatively, you can specify the device using `USB_DEVICE=/dev/disk/by-label/REAR-000`.

If you combine this with `OUTPUT=USB` you will end up with a bootable USB device.

!!! note
    With **USB** we refer to all kinds of external block devices, like USB keys, USB disks, eSATA disks, ZIP drives.
    An USB device needs to be formatted before you can use it with ReaR.
    `rear format` has now in addition to the `--efi` switch a `--bios` switch.
    If none is given (i.e. by default) it will now do hybrid formatting
    with a BIOS boot partition (on GPT) and an EFI system partition.

Optional settings:

* **BACKUP_PROG=rsync**:
If you want to use rsync instead of tar (only for `BACKUP=NETFS`). Do not confuse this with the *BACKUP=RSYNC* backup mechanism.

* **NETFS_KEEP_OLD_BACKUP_COPY=true**:
If you want to keep the previous backup archive. Incremental or differential backup and NETFS_KEEP_OLD_BACKUP_COPY contradict each other so that
`NETFS_KEEP_OLD_BACKUP_COPY` must not be 'true' in case of incremental or differential backup.

* **TMPDIR=/bigdisk**:
Define this variable in `/etc/rear/local.conf` if directory `/tmp` is too small to contain the ISO image, e.g. when using

```bash
    OUTPUT=ISO
    BACKUP=NETFS
    BACKUP_URL=iso://backup
    ISO_MAX_SIZE=4500
    OUTPUT_URL=nfs://lnx01/vol/lnx01/linux_images_dr
```

The `TMPDIR` is picked up by the `mktemp` command to create the `BUILD_DIR` under `/bigdisk/tmp/rear.XXXX`
Please be aware, that directory `/bigdisk` must exist, otherwise, `rear` will bail out when executing the `mktemp` command.
The default value of `TMPDIR` is an empty string, therefore, by default `BUILD_DIR` is `/tmp/rear.XXXX`

Another point of interest is the `ISO_DIR` variable to choose another location of the ISO image instead of the default location (`/var/lib/rear/output`).


## Using RSYNC as backup mechanism
When using *BACKUP=RSYNC* you should provide the backup target location through the `BACKUP_URL` variable. Possible `BACKUP_URL` settings are:

```bash
    BACKUP_URL=rsync://root@server/export/archives
    BACKUP_URL=rsync://root@server::/export/archives
```
