# Release Notes for Relax-and-Recover version 2.6

This document contains the release notes for the open source project
Relax-and-Recover.

[Relax-and-Recover website](http://relax-and-recover.org/)

[GitHub project](https://github.com/rear/)


## Product Features
The following features are supported by the most recent releases of
Relax-and-Recover. Anything labeled as (*New*) was added as the
most recent release. New functionality for previous releases can be
seen in the next chapter that details each release.

The most recent release of Relax-and-Recover is supported on most GNU/Linux
based systems with kernel 2.6 or higher. It provides the following
functionality:

* Hot maintenance capability. A recovery/rescue image can be made online while
  the system is running

* Command line interface. Relax-and-Recover does not require a graphical
  interface to run, neither in creation mode, nor in recovery mode (console
  is enough)

* Support included for most common file systems, such as ext2, ext3, and ext4.
  Other filesystems like reiserfs, jfs, xfs, and btrfs are also implemented,
  but are less tested. _(Feedback is appreciated)_

* Selected Hardware RAID and (eg. HP SmartArray) and mirroring solutions (eg.
  DRBD) are supported

* NVME and mmcblk disks are supported

* LVM root volumes are supported

* Multipath support for SAN storage

* UEFI support (including UEFI USB booting)

* Integrates with _internal_ backup programs such as:

   - GNU tar (BACKUP=NETFS, BACKUP_PROG=tar)
   - GNU tar (BACKUP=NETFS, BACKUP_PROG=tar, BACKUP_TYPE=incremental, FULLBACKUPDAY="Mon") for using incremental backups with a weekly full backup. Be aware, old tar archives will not be removed automatically!
   - GNU tar (BACKUP=NETFS, BACKUP_PROG=tar, BACKUP_TYPE=differential, FULLBACKUPDAY="Mon") for using differential backups with a weekly full backup. Be aware, old tar archives will not be removed automatically!
   - GNU tar with openssl encryption (BACKUP=NETFS, BACKUP_PROG=tar, BACKUP_PROG_CRYPT_ENABLED=1)
   - rsync on local devices (BACKUP=NETFS, BACKUP_PROG=rsync), such USB and local disks
   - rsync over the network (BACKUP=RSYNC, BACKUP_PROG=rsync)
   - Multiple backup methods ([read the documentation](https://github.com/rear/rear/blob/master/doc/user-guide/11-multiple-backups.adoc))
   - Any partition (e.g. a Windows partition) via BACKUP=BLOCKCLONE. See [the documention about BLOCKCLONE](https://github.com/rear/rear/blob/master/doc/user-guide/12-BLOCKCLONE.adoc)
   - BACKUP=ZYPPER is SLES12 only (*Experimental*)
   - BACKUP=YUM is for RedHat architectures ony (*Experimental*)

* Integrates with _external_ backup solutions such as:

  - Tivoli Storage Manager (BACKUP=TSM)
  - Data Protector (BACKUP=DP)
  - Symantec NetBackup (BACKUP=NBU)
  - Galaxy 5, 6, and 7 (BACKUP=GALAXY)
  - Galaxy 10 [Commvault Simpana] (BACKUP=GALAXY10)
  - Bacula (BACKUP=BACULA)
  - Bareos (BACKUP=BAREOS) (A fork of Bacula)
  - Rsync Backup Made Easy (BACKUP=RBME)
  - Duplicity/Duply (BACKUP=DUPLICITY)
  - EMC Networker, also known as Legato (BACKUP=NSR)
  - EMC Avamar (BACKUP=AVA)
  - SEP Sesam (BACKUP=SESAM)
  - FDR/Upstream (BACKUP=FDRUPSTREAM)
  - Novastor NovaBACKUP DC (BACKUP=NBKDC)
  - Borg Backup (BACKUP=BORG)
  - Rubrik Cloud Data Management (BACKUP=CDM) (*New*) 

* Integrates with [Disaster Recovery Linux Manager (DRLM)](http://drlm.org)

* Udev support (except for some really ancient udev versions) which is
  the base for many important features:

  - kernel drivers for network cards and storage adapters are loaded via udev
  - deal with network persistent names in udev rules
  - firmware loading
  - persistent storage device names (though Relax-and-Recover does nothing with this)

* Systemd support for the more recent Linux distributions

* System migration and reconfiguration ('MIGRATION_MODE')

  - facilitate recovery on hardware, that is not the same as the original system
  - network and storage drivers are adjusted
  - map hard disks if they do not match (e.g. hda -> sda)
  - remap network MAC addresses
  - use another IP address, or using dhcp via templates or from kernel command line
  - rebuild the initial ramdisk if needed (for new storage drivers)
  - migration to SAN storaged

* Support backup software: Bacula, both locally attached tapes (with
  bextract) and network-based backups. Also, in combination with OBDR tapes.

* Create OBDR tapes with method `mkbackup` and put the backup onto the tape
  to have a single-tape bootable recovery solution

* Label the OBDR tape with the method `format` to avoid accidental
  overwrites with OBDR

* Create bootable disk (eSATA, USB ...) medium with the backup included:

    BACKUP_URL=usb:///dev/device

    Together with `OUTPUT=USB` we have a complete solution on hard disks
    (booting of it and restoring data).

* DHCP client support (IPv4 and IPv6). Dhcp client activation
  can be forced via the variable *USE_DHCLIENT=yes* (define in _/etc/rear/local.conf_).
  It is also possible to force DHCP at boot time with kernel option `dhcp`

* `USE_STATIC_NETWORKING=y`, will cause statically configured network settings to be applied even when `USE_DHCLIENT` is in effect

* Save layout and compare layouts for automation of making
  Relax-and-Recover snapshots (checklayout option)

* External USB booting uses extlinux (instead of syslinux), and
  therefore, the USB disk must first be formatted with an ext2, ext3, ext4
  or btrfs based file system

* VLAN tagging, teaming and bridge support

* Add timestamp of ReaR run with rc code to the syslog or messages file; sending mail report is also possible

* The possibility to backup any partition (in particular a Windows partition) via the BACKUP type BLOCKCLONE

* Unattended ReaR recovery has been improved

* Improved security model related to SSH keys

  - SSH_FILES='avoid_sensitive_files' (see details in _/usr/share/rear/conf/default.conf_)
  - SSH_UNPROTECTED_PRIVATE_KEYS='no' (see details in _/usr/share/rear/conf/default.conf_)

!!! note
    Features marked *Experimental* are prone to change with future releases.


## ReaR release 2.6 (June 2020)


New features, bigger enhancements, and possibly backward incompatible changes:

* Initial preliminary first basic support for IBM Z architecture "s390x"
(a.k.a. "z Systems", formerly "System/390", simply called "s390") :
Currently primarily for Red Hat and SUSE enterprise systems
so that interested users can try out early how far things work
in their particular IBM Z environments and provide feedback
preferably plus needed fixes, adaptions, and enhancements
to ReaR upstream at https://github.com/rear/rear
(issues #2137 #2142).

* New BACKUP=CDM method to support Rubrik Cloud Data Management (CDM):
The Rubrik CDM backup and restore method for ReaR allows Rubrik CDM
to perform bare metal recovery of Linux systems.
It does this by including the Rubrik CDM RBS agent files in the
ReaR recovery system so that during `rear recover` the Rubrik CDM RBS agent
can be used to restore from Rubrik CDM (issue #2248).

* New use-case for BLOCKCLONE backup method with the "multiple backups" approach
for a more complex LUKS setup with different passphrases or keys:
The usual support for LUKS-encrypted filesystems means that during `reare recover`
a new encrypted filesystem will be created with new encryption keys.
To recover the exact LUKS setup including its keys from the original system
it is now possible to use the "multiple backups" approach by first ignoring
the encrypted filesystem during the "base system" phase, and then
using a second BLOCKCLONE phase with a `dd` image that contains
the encrypted filesystem. The new config variable BLOCKCLONE_TRY_UNMOUNT
is needed here: It will try to unmount the encrypted filesystem
before creating its image and before restoring it (issue #2200).

* Initial draft implementation of the new 'mountonly' workflow
to use ReaR as rescue system, therein mount the filesystems
of the target system so that one can manually repair it.
This is described in doc/user-guide/04-scenarios.adoc
(issue #2247).

* Enable creation of non consecutive partitions.
`parted` is not capable of creating non-consecutive partitions.
To still be able to do so, the trick consists in creating dummy partitions
to fill the gaps between partition numbers. Allocation of these dummy partitions
is done from the end of the target partition, because parted is not capable
of resizing a partition from the beginning (issues #2081 #1793 #1771 #1681).

* Improved handling of partition label type for multipath disks plus
including of multipath disks in backup (unless AUTOEXCLUDE_MULTIPATH is true).
Now the partition label type for multipath devices (same as is already done
for normal disks) is stored in 'multipath' entries in disklayout.conf
so that the syntax of those entries changed and that new syntax is now
documented in doc/user-guide/06-layout-configuration.adoc (issues #2234 #2236).

* The config variable WAIT_SECS default value was aligned
with the USER_INPUT_TIMEOUT default value so that now
the default timeout for user input is always 300 seconds.
The former WAIT_SECS default value of 30 seconds was too short
because the 'read -t' timeout interrupts ongoing user input.
The timeout must be sufficiently long for the user to read and
understand the possibly unexpected user input request message
and then some more time to make a decision what to enter and
finally even more time to enter the right value (issue #2257).

* Enhanced default AUTOEXCLUDE_PATH=( /media /run /mnt /tmp )
to automatically exclude temporarily mounted things (e.g. USB devices)
because mountpoints for temporarily mounted things are usually
sub-directories below /media /run (like /run/media) /mnt
and /tmp (issue #2239).

* Now we have CLONE_ALL_USERS_GROUPS="true" by default.
See the explanation in default.conf what that means.
(issue #2345)

* Replaced grub-mkimage with more sophisticated grub-mkstandalone when
building GRUB2 image for using GRUB2 as recovery system UEFI bootloader
(issue #2293).

## Details (mostly in chronological order - newest topmost):

* Added DHCP auto-configuration for Network Manager (Ubuntu 20.04 Desktop):
While ReaR supports DHCP auto-detection during 'rear mkrescue' of some DHCP setups,
the Network Manager flavor on Ubuntu 20.04 Desktop was not supported
so DHCP for the recovery system was not auto-enabled there
(issue #2427).

* OPALPBA (OUTPUT=RAWDISK): Workaround for EFI firmware glitch
which prevents booting the real OS after unlocking SEDs.
Symptom: Boot hangs when Grub hands over control to the Linux kernel.
Seen on an HPE ML10Gen9 server. The workaround is to add and remove
a UEFI 'next boot' entry (essentially a no-op) which should convince
the EFI firmware to use the boot order to determine the effective
boot entry for the next boot
(issue #2425).

* Update default.conf:
Describe LUKS_CRYPTSETUP_OPTIONS usage with some examples
(issue #2389).

* Overhauled how SSH config files are parsed for 'IdentityFile' values
to find (and remove) unprotected SSH keys in the recovery system.
Now "find ./etc/ssh" ensures that SSH 'Include' config files
e.g. in /etc/ssh/ssh_config.d/ are also parsed
(issue #2421).

* Update default.conf:
Describe usage of non-quoted globbing patterns like VAR+=( /directory/* )
versus quoted globbing patterns like VAR+=( '/directory/*' )
and also describe how to prepend to an array in contrast to append to it
(issue #2417).

* When creating md5sums of the files in the recovery system
be safe against blanks or special characters in file names
by using appropriate options for all commands in the pipe
(issues #2407 #1372).

* Evaluate OUTPUT_LFTP_OPTIONS at the beginning of lftp operations.
Before OUTPUT_LFTP_OPTIONS had been evaluated after connection
to destination host was established which prohibited using
OUTPUT_LFTP_OPTIONS also for connection specific settings.
Now OUTPUT_LFTP_OPTIONS is moved to the beginning of lftp command
before any other lftp command is executed
(issue #2410).

* For BACKUP=BORG implemented pagination when selecting the Borg archive
to restore from: During "rear recover" all Borg archives are shown.
In case of a long list only the last items had been visble to the user.
Now pagination happens with a configurable number of Borg archives,
see BORGBACKUP_RESTORE_ARCHIVES_SHOW_MAX in default.conf
(issue #2408).

* For BACKUP=BORG updated generated locale filename
from "rear.UTF-8" to "en_US.UTF-8"
(issue #2402).

* Use plain ${COPY_AS_IS[*]} instead of quoted "${COPY_AS_IS[@]}"
in the tar command call that copies things into the recovery system
to ensure "things work as usually expected" for any methods
that are used to add elements to the COPY_AS_IS array and
better explain in default.conf how COPY_AS_IS works,
in particular that symlinks cannot be followed and
that files or directories that contain blanks or
other $IFS characters cannot be specified
(issue #2405).

* For RAWDISK output add distribution-specific GRUB2 module 'linuxefi.mod'
otherwise GRUB2 could not boot a UEFI rescue medium on Ubuntu 18.04 or 20.04
(issue #2419).

* ReaR was using hard-coded set of Grub2 modules for UEFI boot-loader.
New GRUB2_MODULES_UEFI and GRUB2_MODULES_UEFI_LOAD config variables
for installing GRUB2 as recovery system UEFI bootloader
so that user can add or remove GRUB2 modules as needed
(issues #2283 #2293 #2392).

* No longer load GRUB2 modules efi_gop and efi_uga in function create_grub2_cfg :
In the create_grub2_cfg function in lib/bootloader-functions.sh
do no longer enfore loading the GRUB2 modules efi_gop and efi_uga
because loading only the module all_video is sufficient and fail-safe
because moddep.lst contains "all_video: efi_gop efi_uga"
(issue #2388).

* No longer load video_bochs and video_cirrus by the create_grub2_cfg function.
In the create_grub2_cfg function in usr/share/rear/lib/bootloader-functions.sh
that is used in case of UEFI to set up GRUB2 as bootloader for the recovery system
do no longer let GRUB2 load the modules video_bochs and video_cirrus
because those are not available as GRUB2 modules in case of UEFI (x86_64-efi)
and the generic "insmod all_video" that is still there should be sufficient for GRUB2
(issue #2388).

* Allow to boot original system from Grub menu (UEFI):
This change adds following:
Possibility to boot original system for UEFI boot with OUTPUT=NETFS
and OUTPUT=USB (similarly to non UEFI ReaR rescue system).
Replaces grub-mkimage for building of Grub2 boot image for OUTPUT=USB
with build_bootx86_efi() (grub-mkstandalone).
Replaces separate Grub configuration for OUTPUT=USB with create_grub2_cfg().
Using build_bootx86_efi() and create_grub2_cfg() in OUTPUT=USB will
unify process of Grub boot image creation with OUTPUT=NETFS.
(issue #2326)

* Replace grub-mkimage with more sophisticated grub-mkstandalone when
building GRUB2 image for using GRUB2 as recovery system UEFI bootloader
(issue #2293).

* When transferring ReaR recovery system ISO,
create also destination directory structure (including parents).
This is useful because when destination directory structure does not exist
(or is incomplete), Lftp puts files into first available directory in OUTPUT_URL scheme
(issue  #2401).

* Have CLONE_ALL_USERS_GROUPS="true" by default and explain it in default.conf
(issue #2345).

* New OUTPUT_LFTP_OPTIONS config variable for lftp custom parameters
(issue #2384).

* Update 950_check_missing_programs.sh:
When checking for required programs also test for "basename program"
because when required programs are specified with absolute path
those programs appears in the ReaR recovery system in /bin/
so testing their original path would falsely fail during "rear recover"
(issue #2206).

* New prep/USB/<non-i386-arch>/350_safeguard_error_out.sh
safeguard scripts to let "rear mkrescue/mkbackup" error out
in case of false usage of OUTPUT=USB on non PC-compatible
(non-i386/x86/x86_64) architectures because with OUTPUT=USB
on those architectures the USB medium cannot be booted
(for those architectures there are no scripts that install a bootloader)
and documented that in the OUTPUT=USB section in default.conf
(issues #2348 #2396).

* Error out for unsupported workflows in any case:
Before init/default/050_check_rear_recover_mode.sh did only error out
when in the recovery system an unsupported workflow should be run.
Now it also errors out when on the normal/original system
an unsupported workflow that is likely destructive
(in particular recover layoutonly restoreonly finalizeonly and mountonly)
should be run
(issues #2387 #2395).

* Improve BorgBackup (short: Borg) integration into ReaR:
Several improvements e.g. error handling, output to logfile etc.
(issue #2382).

* In backup/NETFS/default/500_make_backup.sh add "bs=1M" to
SPLIT_COMMAND="dd of=$backuparchive bs=1M"
to let 'dd' read and write up to 1MiB at a time to speed up things
for example from only 500KiB/s (with the 'dd' default of 512 bytes)
via a 100MBit network connection to about its full capacity
(issue #2369).

*  Error out during "rear mkrescue/mkbackup" when LUKS version 2 is used
because LUKS version 2 is not suppported.
When LUKS version 2 is used it fails at least to determine the hash value
so we use an empty hash value as a simple test if gathering crypt information
was successful and error out if not.
(issues #2204 #2381)

* Auto-detect DHCP client with systemd-networkd
plus completely overhauled and simplified code in
prep/GNU/Linux/210_include_dhclient.sh
with resulting simplification of
skel/default/etc/scripts/system-setup.d/58-start-dhclient.sh
(issue #2375).

* Filter out duplicate entries in COPY_AS_IS
but keep the ordering of the elements
i.e. only the first occurrence of an element is kept.
Also remove duplicates in the copy_as_is_filelist_file
with 'sort -u' because here the ordering does not matter.
(issue #2377)

* Update 250_find_all_libs.sh:
Removed unreliably working code that intends to filter out
duplicates in the LIBS and COPS_AS_IS arrays via
echo "${ARRAY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '
that fails when array elements contain spaces
so better code should be used e.g. like
printf '%s\n' "${ARRAY[@]}" | awk '!seen[$0]++'
but filtering out duplicates is not needed
and by the way cleaned up the whole script a bit.
(issue #2377)

* Skip Longhorn Engine replica devices (issue #2373).

* Update 400_prep_yum.sh:
For BACKUP=YUM error out if BACKUP_PROG_CRYPT_ENABLED is set
because BACKUP=YUM does not support backup encryption
(issue #2374).

* Fail-safe patching of etc/ssh/sshd_config in the recovery system
to ensure the needed ReaR settings/overrides actually apply.
For example if etc/ssh/sshd_config contains a Match section
at the end of the file e.g. appending "PermitRootLogin yes"
will not be effective as a global setting but only in the Match section.
Therefore now the needed ReaR settings are inserted at the beginning
and all subsequent entries of that kind are disabled (commented out)
to ensure that the ReaR global setting is the only one that is effective.
(issue #2362)

* Run what was build/default/985_fix_broken_links.sh
now earlier as build/default/490_fix_broken_links.sh
before files get modified in recovery system because
otherwise e.g. if etc/ssh/sshd_config is a symbolic link
build/default/500_ssh_setup.sh will fail to apply patches
(issue #2360).

 * Use simpler and more fail-safe syntax
 ARRAY+=( additional elements )
 everywhere (issue #2364).

* Update 58-start-dhclient.sh: Fixed issue #2354.

* Added usr/share/rear/restore/OPALPBA/ directory
to pass the test for $SHARE_DIR/restore/$BACKUP
in prep/default/035_valid_backup_methods.sh
because the mkopalpba workflow uses the nonexistent
BACKUP method OPALPBA to create a PBA image
(issue #2351).

* Fix OPALPBA: Could not change password on multiple SEDs at once.
"rear opaladmin changePW" (when used without any extra argument
or with multiple arguments) is meant to change the disk password
on multiple self-encrypting drives in a single invocation.
However, it stopped after successfully changing the password on the first drive
and the password of subsequent drives had not been changed. 
(issue #2349)

* Update 035_valid_backup_methods.sh:
Simplified prep/default/035_valid_backup_methods.sh
to make it work more predictable and fail-safe
(issue #2353).

* Have a hardcoded '-iso-level 3' option in
output/ISO/Linux-ppc64le/820_create_iso_image.sh
because it is also hardcoded in
output/ISO/Linux-i386/820_create_iso_image.sh
and it seems to also work in general on PPC64LE architecture
(issue #2344).

* Update default.conf: Adapt the explanation in default.conf how ISO_MAX_SIZE works
(issue #2347).

* Cleaned up and enhanced the ISO_MAX_SIZE implementation
in backup/NETFS/default/500_make_backup.sh to make it in particular more safe
against erroneous settings of the ISO_MAX_SIZE variable
(issue #2344).

* Added required NFS users for proper rpcbind startup: Usually 'rpcuser' is used
but 'rpc' is used in RHEL7.x and '_rpc' is used in Debian 10
(issues #2341 #2342 #2250)

* Cleaned up and enhanced 320_migrate_network_configuration_files.sh
plus some bugfixes where the old code presumably did not work.
(issues #2310 #2313 #2312)
   
* Update 890_finish_checks.sh: In the WARNING message at the end of "rear recover"
when no bootloader could be installed also mention
usr/share/rear/finalize/Linux-ppc64le/660_install_grub2.sh
as an example script how one could install a bootloader on POWER architecture.
Furthermore since finalize/default/110_bind_mount_proc_sys_dev_run.sh
it is no longer needed to manually mount /proc.
(issues #2339 #2045)

* Update 095_exclude_non_essential_files.sh: Added also /usr/lib/grub2
and /usr/share/grub2 to COPY_AS_IS_EXCLUDE because since openSUSE Leap 15.1
things were moved from /usr/lib/grub2/ to /usr/share/grub2/
(issue #2338).

* Update 270_create_grub2_efi_bootloader.sh: Test for Grub 2 EFI
components directories /usr/lib/grub/x86_64-efi and now also for
/usr/lib/grub2/x86_64-efi or /usr/share/grub2/x86_64-efi
because since openSUSE Leap 15.1 things were moved
from /usr/lib/grub2/ to /usr/share/grub2/
(issue #2338).

* Update uefi-functions.sh: Use /usr/*/grub*/x86_64-efi/partmap.lst
instead of /usr/lib/grub*/x86_64-efi/partmap.lst because since
openSUSE Leap 15.1 things were moved from /usr/lib/grub2/ to /usr/share/grub2/
(issue #2338).

* Update 630_install_grub.sh and 650_install_elilo.sh:
Show the actual missing directory in the Error message
(issue #2337).

* Moved backup/default/005_valid_backup_methods.sh
to prep/default/035_valid_backup_methods.sh to also
check for valid backup methods during "rear mkrescue"
because for most external backup methods only "rear mkrescue" is used,
cf. the section "BACKUP SOFTWARE INTEGRATION" in 'man rear'
(issue #2337).

* Changes to Data Protector branding, adjustment required to support
the new Data Protector 10.x agent with Secure Socket Communication.
Fixed some problems related to SessionID format and problems with
object names like host type vs. file system backup
(issue #2335).

* Hard-coded root home directory string ("/root") was replaced
with $ROOT_HOME_DIR that is the eeal home directory of root user
(issue #2334).

* Make USE_DHCLIENT and USE_STATIC_NETWORKING more fail-safe
in ReaR recovery system (issue #2325).

* For FDR backups, if the path for $FDRUPSTREAM_DATA_PATH does not exist,
then create it. This change is FDR specific for s390 and is only in effect
if ZVM_NAMING is "Y" (issue #2320).

* Overhauled rescue/default/010_merge_skeletons.sh:
Made 010_merge_skeletons.sh behave more reliably. 
Now it errors out when things really went wrong.
Now is is also supported that both a $skel_dir directory
(e.g. usr/share/rear/skel/default/) plus a $skel_dir.tar.gz
(e.g. usr/share/rear/skel/default.tar.gz) exist and
then both get copied into the recovery system,
first the directory and then the tar.gz so that
via the tar.gz files from the $skel_dir directory
could be overwritten if needed.
(issues #2307 #2317)

* Added $FDRUPSTREAM_DATA_PATH/rear to $COPY_AS_IS_EXCLUDE_FDRUPSTREAM
(issue #2318).

* Added documentation about possible (dirty) workarounds 
for needed bind9-export libraries for CentOS 7.7 and 8.0
which is somewhat related to Rubrik-CDM
(issues #2266 #2284).

* Enhanced recovery system BIOS boot default settings for USB and ISO:
For OUTPUT=ISO the user can now explicitly specify
what to boot by default when booting the ISO on BIOS systems via
ISO_DEFAULT="boothd0" to boot from the first disk and
ISO_DEFAULT="boothd1" to boot from the second disk.
For OUTPUT=USB the user can now explicitly specify
what to boot by default when booting the disk on BIOS systems via
USB_BIOS_BOOT_DEFAULT="boothd0" to boot from the first disk.
The default USB_BIOS_BOOT_DEFAULT="" boots the second disk.
(issues #2276 #2303)

* Remove outdated /root/rear-DATE-TIMESTAMP.log symlinks.
Before creating the current symlink to the current log file
test all files that match the file name pattern of such symlinks
and remove those already existing (old) symlinks where its
now outdated symlink target is the current log file
(issue #2301).

* Initial preliminary first basic support for IBM Z architecture "s390x"
(a.k.a. "z Systems", formerly "System/390", simply called "s390") :
Currently primarily for Red Hat and SUSE enterprise systems
so that interested users can try out early how far things work
in their particular IBM Z environments and provide feedback
preferably plus needed fixes, adaptions, and enhancements
to ReaR upstream at https://github.com/rear/rear
(issues #2137 #2142).

* Improved 'is_multipath_path' function to be more fail safe
that now tests (via "multipath -l" output) if multipath is used.
Additionally have 'lsblk' output as disklayout.conf header comments
to make it easier to understand the values in the subsequent entries.
Furthermore added 'xdd' to the PROGS array because sometimes
a tool to display binary files is required in the recovery system.
(issue #2298).

* Error out during "rear mkrescue" in case of insufficient LVM tools:
Overhauled layout/save/GNU/Linux/220_lvm_layout.sh
where now the exit code of the "lvm ..." calls are checked
and it errors out if one fails in particular to avoid that
entries in disklayout.conf are missing or broken
when too old LVM tools are used that do not support
the needed options of those "lvm ..." calls.
Also in layout/save/default/950_verify_disklayout_file.sh
a simple test was added to verify that the 'lvm...' entries
in disklayout.conf look syntactically correct.
Furthermore in 06-layout-configuration.adoc in the
"Disk layout file syntax" section the exact same syntax
for the "lvm..." entries is now listed as the headers
of the "lvm..." entries in disklayout.conf are.
(issues #2259 #2291)

* Fixed missing delete_dummy_partitions_and_resize_real_ones calls:
Use same code as for disks for multipath devices (these are just regular disks),
including MBR erasing and partition creation and cleanup : create_multipath()
cannot call create_disk() because create_disk() verifies that the device
is a block device, which it isn't with multipath because it's a symlink
to a device mapper instead. Make sure new code handling re-creation
of partitions and cleanup is used because Software Raid can have partitions
since these are virtual disks.
(issue #2281)

* Moved 'route' back from REQUIRED_PROGS to PROGS.
ReaR uses 'ip route' everywhere so 'route' is not actually required.
As 'route' is no longer always installed nowadays, having it
in REQUIRED_PROGS lets ReaR falsely error out on such systems
(issues #1961 #1652).

* Update 990_verify_rootfs.sh: Use a FDRUPSTREAM-specific
LD_LIBRARY_PATH to find FDR libraries (issue #2296).

* Do not run 'ldd' on untrusted files to mitigate
possible ldd security issues because some versions
of ldd may directly execute the file (see "man ldd")
which happens as user 'root' during "rear mkrescue".
The new TRUSTED_FILE_OWNERS user config array
contains user names that are trusted owners of files
where RequiredSharedObjects calls ldd (cf. COPY_AS_IS)
and where a ldd test is run inside the recovery system
that tests all binaries for 'not found' libraries.
Furthermore use '2>>/dev/$DISPENSABLE_OUTPUT_DEV'
at more places to avoid that the "rear -D mkrescue" log
file size would grow from about 5 MiB to about 17 MiB
so that now that log file size even shrinked to about 2 MiB.
(issue #2279)

* Initial draft implementation of the new 'mountonly' workflow
to use ReaR as rescue system, therein mount the filesystems
of the target system so that one can manually repair it.
This is described in doc/user-guide/04-scenarios.adoc
(issue #2247).

* Feature RAWDISK and OPALPBA improvements:
RAWDISK: include additional Grub modules from
/boot/grub (and /boot/grub2) which had formerly been missing.
OPALPBA: improve Plymouth boot animation on Ubuntu,
provide integration capabilities for other distros.
RAWDISK: add support for distros which use 'grub2' naming.
(issue #2275)

* Improved check for missing libraries in 990_verify_rootfs.sh
so that now also libraries are checked that are no executables
plus skipped the ldd test for firmware files
(issue #2279).

* Update default.conf: More explanatory comment in default.conf
how COPY_AS_IS versus LIBS, PROGS, and REQUIRED_PROGS are meant to be used
(issue #2278).

* Accommodate logs from multiple FDR/Upstream services.
Users may run multiple FDR/Upstream services on a single machine.
This code change allows ReaR to copy FDR/Upstream logs from the
recovery environment to the restored system for all running services.
Previously the code was expecting to find only one set of logs
and reports in the FDR/Upstream installation directory.
For several years now, logs and reports have been stored in a new
location ($FDRUPSTREAM_DATA_PATH), so we check here instead
(issue #2251).

* Update format-workflow.sh: Set EXIT_FAIL_MESSAGE=0 before exiting
in "rear format -- --help" to avoid the
"rear format failed, check ...rear...log for details"
message that is pointless in this case.

* Added alternative for 'poweroff.com' that is 'poweroff.c32' on RHEL8
(issue #2238).

* Removed unnecessary line that sets NSRSERVER
in layout/save/NSR/default/650_check_iso_recoverable.sh
which prevented setting NSRSERVER in local.conf 
(issue #2162).

* Enhanced default AUTOEXCLUDE_PATH=( /media /run /mnt /tmp )
plus explanatory comment in default.conf how AUTOEXCLUDE_PATH works
(issues #2239 #2261).

* Use is_true() for AUTOEXCLUDE_MULTIPATH and
cleanup of the get_partition_number function
that now errors out with BugError in cases that are
likely a bug in ReaR (issues #2245 #2260).

* Do not abort in case of invalid user input but retry if possible.
When input values can be (syntactically) validated there is now
a retry loop until the user provided valid input (or intentionally aborts)
except those cases where it was not possible to implement validation
when it is unknown what is valid for third-party tools (issue #2253).

* Removed '2>/dev/null' redirection where possible: 
Some general cleanup for ReaR 2.6. in all scripts 
by removing '2>/dev/null' where it makes sense 
and replacing '&>/dev/null' by '1>/dev/null' where it makes sense 
or also removing '&>/dev/null' where that seems to be better (issue #1395).
By the way verify/TSM/default/390_request_point_in_time_restore_parameters.sh
and verify/NBU/default/390_request_point_in_time_restore_parameters.sh 
have been somewhat overhauled but both scripts still abort 'rear recover'
when the user did an invalid date or time input (issue #2253).

* Fix including of multipath disks in backup: 
The AUTOEXCLUDE_DISKS logic traverses filesystems and tries 
to determine the associated underlying disks that should be kept. 
When having a filesystem fs:/A that is present on a multipath 
device MP and the root filesystem fs:/ that is present on a normal 
disk D, the code first established that fs:/A depends on fs:/ 
resulting in marking D as used and then short-circuited processing 
of multipath devices. This resulted in MP not being considered 
as a used device and removed from the backup. 
The problem is fxed by removing the short-circuit logic in 
find_disk_and_multipath() so multipath devices get processed 
too unless AUTOEXCLUDE_MULTIPATH is true (issue #2236).

* Improve handling of partition label type for multipath disks: 
When recording information about a multipath disk, 
ReaR did not store information about its partition label type 
in the 'multipath' entry in disklayout.conf. 
The recovery code tried to automatically detect the label type 
using a heuristic that depends on GPT partition names. 
The logic would incorrectly detect the device as having the 
MBR label type instead of GPT if one of the partition names 
was exactly "primary", "extended" or "logical". 
The problem is solved by explicitly storing the partition label type 
for multipath devices (same as is already done for normal disks) 
so that the syntax of the 'multipath' entries in disklayout.conf 
is changed and that new syntax is now documented in 
doc/user-guide/06-layout-configuration.adoc 
The recovery code is accordingly updated to utilize this
information (issue #2234).

* In doc/user-guide/16-Rubrik-CDM.adoc updated links to SUSE documentation: 
Replaced the outdated link 
https://www.suse.com/documentation/sle-ha-12/book_sleha/data/cha_ha_rear.html 
that gets redirected to a not really helpful standard fallback page 
by the currently valid URL for the most recent SLE-HA-15-SP1 
https://documentation.suse.com/sle-ha/15-SP1/html/SLE-HA-all/cha-ha-rear.html 
because meanwhile the SUSE documentation was moved to its own server. 
The more general and more comprehensive documentation URL 
https://en.opensuse.org/SDB:Disaster_Recovery 
is kept and listed topmost (issue #2255).

* Added explanatory comments to default.conf about backup restore
that may fail for things like BACKUP_PROG_COMPRESS_OPTIONS=("--zstd")
due to missing zstd binaries in the ReaR recovery system
probably also for --lzip --lzma --lzop (issue #2241).

* New BACKUP=CDM method for Rubrik Cloud Data Management (CDM)
see doc/user-guide/16-Rubrik-CDM.adoc (issues #2248 #2249).

* In verify/NETFS/default/050_start_required_nfs_daemons.sh 
all kind of '2>/dev/null' (i.e. also '&>/dev/null') are removed 
(so that '&>/dev/null' is replaced by '1>/dev/null') 
because in general '2>/dev/null' is unhelpful
because it needlessly suppresses error messages in the log 
that would be helpful to see when something fails (issues #2250 #1395).

* Update 06-layout-configuration.adoc: Changed section title
from "Including/Excluding components" to only "Excluding components".
The latter avoids possible misunderstanding that there would be
a config variable to explicitly include something but "including" here
describes only to disable autoecludes (issue #2229).

* Update default.conf: At AUTOEXCLUDE_DISKS removed the comment
`Explicitly excluding/including devices is generally a safer option`
because it is not acually helpful and even misleading because there is
currently no config variable to explicitly include devices (issue #2229).

* Do not keep the build dir when ReaR is run noninteractively
by additional special values for the KEEP_BUILD_DIR config variable,
see its desctiption in default.conf (issue #2218).

* Fix LVM2 thin pool recreation logic / use of vgcfgrestore is broken:
Removing forcibly (with '--force' passed twice) seems to work for now.
But our use of vgcfgrestore is probably not appropriate at all.
It works by chance. Typically, it works only for Linear volumes,
and won't probably for Caches and Raid hierarchies
or when there are existing Snapshots on the system.
The only proper solution is perhaps stop relying on vgcfgrestore at all,
but then we are not capable of restoring volume groups and logical volumes
with all properties from original system (issue #2222).

* Use `mountpoint` instead of `mount | grep` (issue #2225).

* Updated default.conf:
Replaced `ARRAY=( "${ARRAY[@]}" additional elements )`
with simpler and more fail safe `ARRAY+=( additional elements )`
(related to issues #2223 #2220).

* Append to the CLONE_USERS and CLONE_GROUPS arrays by using `+=`
instead of expanding the previous value to an empty element
which then causes problems later (issues #2223 #699).

* Update 900_clone_users_and_groups.sh:
Skip empty user and group values (issue #2220).

* New use-case for BLOCKCLONE backup method for complex LUKS-encrypted filesystems
by usinng the "multiple backups" approach with a second BLOCKCLONE phase with a `dd` image that contains the encrypted filesystem where unmounting the encrypted filesystem
before creating its image and before restoring it has to be done via the new
config variable BLOCKCLONE_TRY_UNMOUNT (issue #2200).

* Fixed when ReaR does not detect an uncompressed kernel
that is named 'vmlinux' (instead of 'vmlinuz').

* Added $BACKUP_OPTIONS to the line with mount_url in 800_copy_to_tftp.sh
and 810_create_pxelinux_cfg.sh otherwise in case of OUTPUT=PXE
mounting the NFS will fail.

* UEFI: Search for Grub2 modules in /usr/lib/grub*/x86_64-efi and not in /boot.
On Fedora and RHEL systems, Grub2 UEFI modules live in
/usr/lib/grub*/x86_64-efi, not /boot, unless grub2-install is executed,
but executing this tool is not needed with UEFI.
On SUSE systems, Grub2 UEFI modules also live in /usr/lib/grub*/x86_64-efi
but there is also a copy in /boot, so it's not needed searching in /boot at all.
Additionally, only UEFI modules should be looked for,
so /boot cannot be searched but only /boot/grub2/x86_64-efi
(similarly /usr/lib/grub*/x86_64-efi, not just /usr/lib/grub*),
otherwise we could get some false positives on dual boot systems
(UEFI + Legacy), since modules for Legacy will also match,
which is wrong (issues #2199 #2001). 

* RAWDISK and TCG Opal 2 Self-Encrypting Disks: Add Secure Boot support (issue #2166).

* Avoid that disklayout.conf contains duplicate 'lvmvol' lines:
Create the 'lvmvol' lines commented out when multiple segments exist for a given LV.
This is not an issue unless Migration Mode is used.
In such case, using 'lvcreate' commands already does best effort
and loses LV information (issues #2194 #2187).
Additionally do not overload the `kval` variable
(that is intended for passing options to lvcreate)
by adding extra keys to it, which are not supported by lvcreate.
Introduce another variable `infokval` for this purpose and print
those unsupported and purely informational keys only in comments (issue #2196).

* Apply layout mappings also to other relevant files 
via layout/prepare/default/320_apply_mappings.sh 
In migration mode apply the disk layout mappings 
not only to disklayout.conf but also to other files 
that are also used to migrate the disk layout, namely 
VAR_DIR/layout/config/df.txt and /etc/rear/rescue.conf 
Additionally re-read the BTRFS_SUBVOLUME_SLES_SETUP 
variable from /etc/rear/rescue.conf because its value could 
have been migrated to a new value (issue #2181).

* In the function apply_layout_mappings (therein in its "step 3") 
treat leftover temporary replacement words (like `_REAR1_`) 
as an error only if they are in a non-comment line (issue #2183).

* When 420_autoresize_last_partitions.sh resizes the last partition 
on a GPT disk it leaves 33 LBA blocks at the end of the disk 
so that 420_autoresize_last_partitions.sh produces a fully correct 
disklayout.conf file where no further automated adjustments by 
a subsequent script like 100_include_partition_code.sh are done (issue #2182).

* Error out when DHCLIENT_BIN and DHCLIENT6_BIN 
are empty and USE_DHCLIENT is set (issue #2184).

* In build/default/990_verify_rootfs.sh 
skip the ldd test for kernel modules because in general 
running ldd on kernel modules does not make sense 
and sometimes running ldd on kernel modules causes 
needless errors because sometimes that segfaults (issue #2177).

* Bacula: Fixed 'bconsole' prompt not displaying at all
when doing a recover (issue #2173).

* Fixed that the EFI Boot Manager cannot be installed
when the system has a NVMe SSD, because the device name
is resolved as /dev/nvme0n1p rather than /dev/nvme0n1
so for NVMe devices the trailing 'p' in the Disk value
as in /dev/nvme0n1p that is derived from /dev/nvme0n1p1
needs to be stripped to get /dev/nvme0n1 (issues #2160 #1564).

* Changed double quotes (") to single quotes(') in documentation
related to BORG_PASSPHRASE variable. Double quotes will not avoid
expanding of variable when '$' sign is used inside pass phrase string,
which can lead to unsuccessful opening of Borg archive (issue #2205).

* More fail safe BACKUP_PROG_CRYPT_KEY handling:
Use double quotes `"$BACKUP_PROG_CRYPT_KEY"` so that 
the BACKUP_PROG_CRYPT_KEY value can contain spaces. 
Escape special regexp characters in the BACKUP_PROG_CRYPT_KEY 
value when it is used as a regexp in grep or sed. 
Use single quotes `BACKUP_PROG_CRYPT_KEY='my_passphrase'`
in the documentation examples so that the BACKUP_PROG_CRYPT_KEY 
value can contain special characters (except single quote). 
Recommend in default.conf to not use special characters in the 
BACKUP_PROG_CRYPT_KEY value to be to be on the safe side 
against things breaking in unexpected weird ways when certain code 
in ReaR is not yet safe against arbitrary special characters in values
(issues #2157 #1372).

* Avoid that the BACKUP_PROG_CRYPT_KEY value appears in a log file
in particular when 'rear' is run in debugscript mode where 'set -x' is set
by redirecting STDERR to /dev/null for those confidential commands
that use the BACKUP_PROG_CRYPT_KEY value, cf. the comment of the
UserInput function how to keep things confidential when 'rear'
is run in debugscript mode (issues #2155 #2156).

* Fix when recovery fails on LUKS-encrypted filesystem using simple password
because only the first 2 parameters in /etc/crypttab are mandatory (issue #2151).

* Generic enhancements for IBM Z (s390) to support 'dasd' disks 
and SUSE specific enhancements to install during "rear recover" 
the special GRUB2 plus ZIPL bootloader on SLES12 and later via the 
new finalize/SUSE_LINUX/s390/660_install_grub2_and_zipl.sh script
(issues #2137 #2150).

* Cleanup of the OUTPUT=RAMDISK code.
Overhauled 900_copy_ramdisk.sh as architecture independent 
new script output/RAMDISK/default/900_copy_ramdisk.sh that 
replaces output/RAMDISK/Linux-i386/900_copy_ramdisk.sh 
and overhauled conf/templates/RESULT_usage_RAMDISK.txt 
plus better description of OUTPUT=RAMDISK 
and RESULT_FILES in default.conf (issue #2148).

* Enable creation of non consecutive partitions (issues #2081 #1793 #1771 #1681).

* The new SUSE-specific script finalize/SUSE_LINUX/i386/675_install_shim.sh 
calls 'shim-install' inside chroot on the recreated target system 
and uses boot/grub2/grub.cfg as input to recreate two needed 
(identical) EFI files /boot/grub2/x86_64-efi/core.efi
and /boot/efi/EFI/opensuse/grubx64.efi (issue #2116).

* Fixed that output/default/950_copy_result_files.sh falsely errors out
when an output method OUTPUT=FOO is used where there is no matching
usr/share/rear/conf/templates/RESULT_usage_FOO.txt because when it is missing
it is no sufficient reason to error out.
Furthermore now 950_copy_result_files.sh is skipped  when RESULT_FILES is empty
because that means there is no actual output and then it is not needed
to only copy VERSION README and LOGFILE to the output location (issue #2147).

## System and Software Requirements
Relax-and-Recover works on GNU/Linux kernel with version 2.6 and higher.
For lower kernel versions Relax-and-Recover cannot be used, and for these
systems, [mkcdrec](http://mkcdrec.sourceforge.net/) is still a good
alternative.

As Relax-and-Recover has been solely written in the *bash* language we need
the bash shell which is standard available on all GNU/Linux based systems.
The default backup program Relax-and-Recover uses is GNU/tar which is also
standard available.

Relax-and-Recover is known to work well on x86, x86_64 and ppc64(le) based architectures.
Relax-and-Recover has also been ported to ia64 and arm architectures, but
these are less tested. Use the '`rear validate`' command after every
successful DR test please and mail us the results.


## Choosing the best compression algorithm
The default backup program with Relax-and-Recover is (`BACKUP_PROG=tar`)
GNU tar and the default compression used with tar is `gzip`. However, is
using `gzip` the best choice? We have done some tests and published the
results. See
[Relax-and-Recover compression tests](http://www.it3.be/2013/09/16/NETFS-compression-tests/)

## Support
Relax-and-Recover (ReaR) is an Open Source project under GPL v3 license which means
it is free to use and modify. However, the creators of ReaR have spend many, many hours in
development and support. We will only give *free of charge* support in our free time (and when work/home balance
allows it).

That does not mean we let our user basis in the cold as we do deliver support as a service (not free of charge).

## Supported and Unsupported Operating Systems
We try to keep our wiki page [Test Matrix rear 2.6](https://github.com/rear/rear/wiki/Test-Matrix-rear-2.6) up-to-date with feedback we receive from the community.

ReaR-2.6 is supported on the following Linux based operating systems:

* Fedora 29, 30, 31, and 32
* RHEL 6, 7, and 8
* CentOS 6, 7, and 8
* Scientific Linux 6 and 7
* SLES 12 and 15
* openSUSE Leap 15.x
* Debian 8, and 9
* Ubuntu 16, 17, and 18

ReaR-2.6 dropped official support for the following Linux based operating systems:

* Fedora < 29
* RHEL < 6
* CentOS < 6
* Scientific Linux < 6
* SLES < 12
* openSUSE Leap 42.x and before (i.e. openSUSE <= 13)
* openSUSE Tumbleweed
* Debian < 8
* Ubuntu < 16

Usually ReaR-2.6 should also work on newer versions of the above listed supported Linux based operating systems but sometimes arbitrary failures can happen when software that is used by ReaR (like partitioning tools, filesystem tools, bootloader tools, ISO image creating tools, networking tools, and so on) changes in not fully backward compatible ways or when there are innovations of the basic system (like kernel, storage, bootloader, init, networking, and so on) that are not yet supported by ReaR.

In theory ReaR-2.6 should work on openSUSE Tumbleweed but in practice arbitrary failures could happen at any time because the Tumbleweed distribution is a pure rolling release version of openSUSE containing the latest stable versions of all software (cf. https://en.opensuse.org/Portal:Tumbleweed) so arbitrary changes of any software are possible at any time that could arbitrarily break how ReaR works.

ReaR-2.6 may still work for SLES 11 and openSUSE Leap 42.x or even earlier openSUSE versions but it is no longer sufficiently well tested there so arbitrary regressions could appear.

ReaR 2.6, ReaR-2.5, and ReaR-2.4 (and probably also some earlier versions) are known to no longer work reasonably well for the following Linux based operating systems:

* RHEL 5 (and probably also CentOS 5): See issue #1766
* SLES 9 and 10: See issue #1842

If you require support for *unsupported* Linux operating systems you must acquire a *ReaR support contract*.

Requests to port ReaR to another operating system (not Linux) can only be achieved with **serious** sponsoring.

## Supported and Unsupported Architectures
ReaR-2.6 is supported on:

* Intel x86 type of processors
* AMD x86 type of processors
* PPC64 processors
* PPC64LE processors

ReaR-2.6 may or may not work on:

* Intel Itanium processors
* ARM type of processors
* IBM Z "s390x" type of processors

ReaR-2.6 does not support:

* old PPC (32bit) processors

If you feel the need to get a fully functional ReaR working on one of the above mentioned type of processors please buy
consultancy from one of our official developers.

## Supported ReaR versions
ReaR has a long history (since 2006) and we cannot support all released versions. If you have a problem we urge you to install the latest stable ReaR version or the development version (available on GitHub) before submitting an issue.

However, we do understand that it is not always possible to install on hundreds of systems the latest version so we are willing to support previous versions of ReaR if you buy a support contract. Why do we change our policy? We cannot handle the big support requests anymore and we must give paid projects priority, therefore, we urge our customers to buy a support contract for one or more systems. You buy time with our core developers.
