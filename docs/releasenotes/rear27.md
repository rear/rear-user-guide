# Release Notes for Relax-and-Recover version 2.7

This document contains the release notes for the open source project
Relax-and-Recover.

[Relax-and-Recover website](http://relax-and-recover.org/)

[GitHub project](https://github.com/rear/)


## Product Features
### Features of Relax-and-Recover (ReaR)

### Features of Relax-and-Recover (ReaR)

The most recent release of Relax-and-Recover (ReaR) offers an extensive array of features tailored for GNU/Linux environments running kernel 2.6 or higher. Here’s an expanded look at its capabilities:

- **Hot Maintenance Capability**: Allows creation of a recovery or rescue image while the system is running, ensuring minimal downtime during backup operations.

- **Command Line Interface**: Operates entirely via command line interface, suitable for both creation and recovery modes without requiring a graphical environment.

- **File System Support**: Comprehensive support for various file systems including ext2, ext3, ext4, reiserfs, jfs, xfs, and btrfs, with ongoing improvements based on user feedback.

- **Hardware RAID and Mirroring**: Supports selected hardware RAID configurations (e.g., HP SmartArray) and mirroring solutions (e.g., DRBD) for reliable data redundancy.

- **Disk Support**: Extensive support for modern storage technologies such as NVME and mmcblk disks, ensuring compatibility with diverse storage architectures.

- **LVM Support**: Robust support for LVM (Logical Volume Manager) root volumes, facilitating seamless backup and recovery of complex disk configurations.

- **Multipath Support**: Includes support for SAN storage with multipath configurations, enhancing reliability and performance in storage area networks.

- **UEFI Support**: Fully integrates with UEFI (Unified Extensible Firmware Interface), including support for UEFI USB booting, ensuring compatibility with modern system firmware standards.

- **System Recovery on Dissimilar Hardware**: Facilitates recovery on hardware different from the original system, adjusting network and storage drivers, remapping hard disks (e.g., hda -> sda), and remapping network MAC addresses as necessary.

- **IP Address Configuration**: Supports using another IP address or DHCP via templates or kernel command line options, ensuring flexibility in network configuration during recovery.

- **Initial Ramdisk Management**: Rebuilds the initial ramdisk if needed to accommodate new storage drivers during system recovery.

- **Migration to SAN Storage**: Provides capabilities for migrating and recovering systems to SAN (Storage Area Network) storage environments.

- **Bacula and OBDR Tape Support**: Integrates with Bacula for both locally attached tapes (with bextract) and network-based backups. Supports creating OBDR (One Button Disaster Recovery) tapes using methods like `mkbackup` and labeling tapes with `format` to prevent accidental overwrites.

- **Bootable Disk Creation**: Enables creation of bootable disk mediums (e.g., eSATA, USB) with the backup included, supporting URLs like `usb:///dev/device` and using `OUTPUT=USB` for a complete recovery solution on hard disks.

- **Network Configuration**: Supports VLAN tagging, teaming, and bridge configurations, enhancing network flexibility and performance during recovery.

- **Syslog and Mail Report**: Adds a timestamp of ReaR run with rc code to the syslog or messages file, with the option to send mail reports for comprehensive logging and notification.

- **Partition Backup**: Enables backing up any partition, including Windows partitions, via the BACKUP type BLOCKCLONE, ensuring comprehensive data protection.

- **Unattended Recovery**: Improvements in unattended ReaR recovery processes streamline and automate system restoration tasks.

- **Security Enhancements**: Implements an improved security model related to SSH keys, including options to avoid sensitive files and protect private keys (`SSH_FILES='avoid_sensitive_files'`, `SSH_UNPROTECTED_PRIVATE_KEYS='no'`).

- **LUKS2 Support**: Provides support for LUKS2 encryption, ensuring compatibility and security in encrypted disk configurations.

These features collectively make Relax-and-Recover (ReaR) an indispensable tool for GNU/Linux administrators, providing robust backup, disaster recovery, system migration, and security capabilities across diverse environments and hardware configurations.


## ReaR release 2.7 (July 2022)

### New features, bigger enhancements, and possibly backward incompatible changes:

-   ReaR's default TMPDIR is now `/var/tmp` (it was `/tmp` before) i.e. ReaR's
    default working area is now `/var/tmp/rear.XXXXX` because ReaR needs lots of
    space (from 300MB up to more than 1GB) to build the ReaR rescue/recovery
    system e.g. as ISO image and even much more space to also store the backup
    archive e.g. when the backup should be included in the ISO image. The
    system's default temporary directory /tmp is no longer suited as default
    temporary directory for ReaR because nowadays /tmp is often a "tmpfs" that
    is in RAM so /tmp has RAM/swap limitations and file-hierarchy(7)
    recommends to use /var/tmp for cases as ReaR. If the user sets TMPDIR
    explicitly, it still takes precedence.

-   Stop ReaR from possibly overwriting its own disk and backup drives for
    *OUTPUT=USB* and *OUTPUT=RAWDISK* via new `WRITE_PROTECTED_...` config variables
    (see _/usr/share/rear/conf/default.conf_) where UUIDs or filesystem labels
    can be specified so that disks that contain such UUIDs or filesystem
    labels will be 'write protected' during "rear recover".

-   Added initial LUKS2 support.

-   Overhauled RAID code with changed RAID related entries in
    _/var/lib/rear/layout/disklayout.conf_ so users who use RAID and a selfmade
    _/etc/rear/disklayout.conf_ must adapt their RAID related entries

-   Initial preliminary basic support to automatically resize an active last
    partition on RAID0 and RAID1 disks to be able to automatically resize
    RAID0 and RAID1 arrays

-   Automatically shrink LVs if needed during "rear recover". This enables to
    run "rear recover" with automated LVM LVs shrinking as needed on a bit
    smaller replacement disk (e.g. when a nominally same sized replacement
    disk is actually a bit smaller than the original disk). This automated LVs
    shrinking is not intended when disk(s) are substantially smaller. To
    migrate onto a substantially smaller replacement disk the user must in
    advance manually adapt his disklayout.conf file before he runs "rear
    recover".

-   Support to wipe disks before recreating partitions/volumes/filesystems/...
    (see the new *DISKS_TO_BE_WIPED* in _/usr/share/rear/conf/default.conf_). This
    is currently new and experimental functionality so that currently by
    default via `DISKS_TO_BE_WIPED='false'` no disk is wiped to avoid possible
    regressions until this new feature was more tested by interested users via
    an explicit *DISKS_TO_BE_WIPED* setting.

-   Error out when files greater or equal *ISO_FILE_SIZE_LIMIT* should be
    included in the ISO: See the reasoning in
    _/usr/share/rear/conf/default.conf_ why the default *ISO_FILE_SIZE_LIMIT* is
    2GiB and why we error out when files >= ISO_FILE_SIZE_LIMIT should be
    included in the ISO.

-   Rsync OUTPUT_URLs are now properly supported with *BACKUP=RSYNC*.
    Previously the output went to the location specified by *BACKUP_URL*
    and *OUTPUT_URL* was ignored. One exception was *OUTPUT=PXE*, where the output
    was uploaded to *OUTPUT_URL* in addition to *BACKUP_URL*, but *RSYNC_PREFIX* was
    not respected and the interpretation of the URL was different: A URL of
    the form rsync://[USER@]HOST[:PORT]/PATH was interpreted as using the
    rsync protocol, while in all other cases such URL would be interpreted
    as using rsync over ssh. This special handling is now removed:
    An rsync OUTPUT_URL with *OUTPUT=PXE* now creates the *RSYNC_PREFIX* directory
    at the destination and the URL is interpreted as in all other cases.

-   RAWDISK: Add local rescue partition installation capability: Introduce a
    configuration variable *RAWDISK_INSTALL_GPT_PARTITION_NAME*, which is
    unset by default. When set, the rescue system will be installed to local
    disk partitions having the corresponding name.

-   Allow setting a PBA-specific firmware configuration via the new
    *OPAL_PBA_FIRMWARE_FILES* configuration variable.

-   Support OPAL 2 self-encrypting NVMe disk drives.

-   *OPALPBA*: Provide a permanent unlocking mode as a workaround when the
    firmware did not initialize properly during a 'simple' reboot so the only
    reliable way to boot was a power cycle after Opal disks were unlocked. To
    reboot with unlocked disks there is now a new unlocking mode "permanent"
    via *OPAL_PBA_UNLOCK_MODE* (see default.conf). Reactivating locking is then
    the responsibility of the user. Additionally enhanced security by
    disabling shell access via keyboard interrupt and switching to a password
    hash for *OPAL_PBA_DEBUG_PASSWORD*.

-   POWER architecture (ppc64) support for *BACKUP=DP*: Other platforms
    supporting the Data Protector Disk Agent, but not the Cell Console (GUI)
    that is only available on i386, x86_64 and ia64 are now supported with
    ReaR. This includes in particular ppc64. Checks unavailable on clients
    without the Data Protector Cell Console (GUI) are skipped. In such cases
    backup restore can be done using Data Protector GUI only.

-   NSR enhancement for point-in-time recovery with EMC Networker client: A
    new variable `NSR_CLIENT_REQUESTRESTORE` for the *BACKUP=NSR* workflow has
    been introduced to deal with situations in which the NSR client is
    allowed/granted to perform its recovery action "on its own" but does not
    have full control of the EMC networker service/environment, for details
    see its default.conf section.

-   *BACKUP=NBKDC*: Enhanced ReaR backup and restore to also work with NovaStor
    DataCenter 8.0 and higher plus fixed wording "NovaBACKUP DC" -> "NovaStor
    DC"

-   Support for systemd and parallel restore with Data Protector *BACKUP=DP*:
    Support starting Data Protector daemon 'omni.socket' via systemd in the
    recovery system. Restore performance has been increased by doing parallel
    restores now.

-   Now "rear format" has in addition to the `-efi` switch a `-bios` switch.
    If none is given (i.e. by default) it will now do hybrid formatting with a
    BIOS boot partition (on GPT) and an EFI system partition. Accordingly the
    *USB_DEVICE_PARTED_LABEL* default is no longer "msdos" (see the updated
    description in _/usr/share/rear/conf/default.conf)_. This is a starting point
    for implementing *OUTPUT=USB* support for UEFI and BIOS dual boot from the
    same medium. See [issue 2698](https://github.com/rear/rear/issues/2698),
    [issue 2818](https://github.com/rear/rear/issues/2818)
    and [issue 2829](https://github.com/rear/rear/pull/2829)

-   Overhauled serial console support code. A serial console of the ReaR
    recovery system can now be specified separately for the kernel and the
    recovery system bootloader via the generic config variables
    *USE_SERIAL_CONSOLE* and *SERIAL_CONSOLE_DEVICES* and specific config
    variables *SERIAL_CONSOLE_DEVICES_KERNEL*, *SERIAL_CONSOLE_DEVICE_SYSLINUX* and
    *SERIAL_CONSOLE_DEVICE_GRUB* (see _/usr/share/rear/conf/default.conf_ for
    details)

-   Support for HTTP sources when using PXE: There is a new config variable
    *PXE_HTTP_URL* to specify a HTTP download source for PXE. See the
    *PXE_HTTP_URL* description in _/usr/share/rear/conf/default.conf_

-   In _/usr/share/rear/conf/default.conf_ changed *ISO_VOLID* from "RELAXRECOVER"
    to "REAR-ISO" so the first ISO has the label "REAR-ISO" (8 characters) and
    subsequent ISOs get the labels "REAR-ISO_01" "REAR-ISO_02" ... respectively
    that have 11 characters (the maximum length for FAT volume names) so
    things work now by default when the ISO image is used to (manually) create
    a FAT bootable USB stick Accordingly 'RELAXRECOVER' in variable names was
    replaced. In particular the user config variable for automated input
    *USER_INPUT_RELAXRECOVER_SYMLINK_TARGET* was renamed as
    *USER_INPUT_ISO_SYMLINK_TARGET* so only that new name will work.

### Details (mostly in chronological order - newest topmost):

-   Refactor rsync URL support, fixes rsync *OUTPUT_URL*:
    The code to parse rsync:// URLs was BACKUP_URL specific.
    If one specified *BACKUP=RSYNC* and an *OUTPUT_URL* different from *BACKUP_URL*,
    the OUTPUT_URL was ignored and the output files went to BACKUP_URL.
    Fix by introducing generic functions for rsync URL parsing and
    use them for both BACKUP_URL and OUTPUT_URL, as appropriate.
    Replace all uses of global RSYNC_* variables derived
    from BACKUP_URL by those functions.
    There also was inconsistent special handling for OUTPUT=PXE which is now removed:
    An rsync OUTPUT_URL with OUTPUT=PXE now creates the RSYNC_PREFIX directory
    at the destination and the URL is interpreted as in all other cases.
    See [issue 2831](https://github.com/rear/rear/pull/2831)
    and [issue 2781](https://github.com/rear/rear/issues/2781)

-   Support creation of EFI system partition on systems
    with older 'parted' that do not support the 'esp' keyword:
    In _format/USB/default/300_format_usb_disk.sh_ try
    `sgdisk ... --typecode="partition_number:EF00"` as fallback
    when `parted ... set partition_number esp on` failed.
    See [issue 2830](https://github.com/rear/rear/pull/2830)

-   Set `USB_DEVICE_PARTED_LABEL` to match _format-workflow.sh_:
    In _format/USB/default/300_format_usb_disk.sh_ it is set
    depending on the format workflow option `-b/--bios` or `-e/--efi`
    and in in _prep/USB/Linux-i386/340_find_mbr_bin.sh_ try to
    autodetect what the USB disk partition type is and
    use a specified **USB_DEVICE_PARTED_LABEL** if autodetection fails.
    See [issue 2829](https://github.com/rear/rear/pull/2829)

-   In usr/sbin/rear enhanced the check for other simultaneously running 'rear'
    to let it find running 'rear' instances independent of how it was called by the user
    in particular also when 'rear' is run from a GitHub checkout/clone
    cf. [issue 2826](https://github.com/rear/rear/issues/2826)

-   In _usr/share/rear/lib/format-workflow.sh_ do actually recognise -b/--bios
    options, see [issue 2828](https://github.com/rear/rear/pull/2828)

-   In _layout/prepare/GNU/Linux/110_include_lvm_code.sh_ use a fail-safe
    'yes' pipe for "lvm lvcreate" to pipe as many 'y' as asked for into
    "lvm lvcreate". See [issue 513](https://github.com/rear/rear/issues/513)
    and [issue 2820](https://github.com/rear/rear/issues/2820)

-   Avoid creating a /bin/vim symlink to vi: The symlink is more confusing
    than helpful: If one has both vi and vim, and they are different
    (vi usually has less features), one expects to get the more featureful
    version by executing "vim", but one gets "vi". More importantly, in
    recent Fedora and RHEL, "vi" is a shell script that executes "vim"
    if found, so linking "vim" to "vi" leads to an infinite loop.
    See [issue 2822](https://github.com/rear/rear/pull/2822)

-   RPM spec: update build requirement for Fedora to unblock Packit build and
    run make validate after build, see [issue 2816](https://github.com/rear/rear/pull/2816)

-   In _finalize/Linux-i386/660_install_grub2.sh_ explain that it is also used
    as fallback to install the nowadays most often used bootloader GRUB2
    unless the BOOTLOADER variable tells to install another bootloader (other
    bootloader install scripts check the BOOTLOADER variable),
    cf. [issue 2871](https://github.com/rear/rear/issues/2817#issuecomment-1148488339)

-   Replace 'RELAXRECOVER' in variable names: In _lib/global-functions.sh_ in
    the function mount_url() renamed the user config variable for automated
    input `USER_INPUT_RELAXRECOVER_SYMLINK_TARGET` as
    `USER_INPUT_ISO_SYMLINK_TARGET` because the old name contained a user config
    value: "RELAXRECOVER" was an old default value of ISO_VOLID, see
    [issue 2457](https://github.com/rear/rear/pull/2457) and
    [issue 2813](https://github.com/rear/rear/pull/2813#discussion_r885576867)

-   In default.conf properly describe `PRE_BACKUP_SCRIPT` and `POST_BACKUP_SCRIPT`
    to match what the implementation does, see
    [issue 2735](https://github.com/rear/rear/pull/2735#issuecomment-1145006984) and for
    special cases see
    [issue comment](https://github.com/rear/rear/pull/2735#issuecomment-1148620157)

-   Add `PRE_RECOVERY_COMMANDS` and `POST_RECOVERY_COMMANDS` as alternative to
    `PRE_RECOVERY_SCRIPT` and `POST_RECOVERY_SCRIPT` see the description in
    default.conf how to use them and how they work. See
    [issue 2811](https://github.com/rear/rear/pull/2811) and see also
    [issue 2735](https://github.com/rear/rear/pull/2735) therein in particular
    [comment within issue 2735](https://github.com/rear/rear/pull/2735#issuecomment-1134686196).
    Additionally use LogPrint to show the user the executed commands, see
    [issue 2789](https://github.com/rear/rear/pull/2789)

-   In default.conf describe the new user config variables `USB_BOOT_PART_SIZE`
    and `USB_DEVICE_BOOT_LABEL` - see [PR 2660](https://github.com/rear/rear/pull/2660)

-   Exclude `dev/watchdog*` from the ReaR recovery system: In default.conf add
    `dev/watchdog*` to `COPY_AS_IS_EXCLUDE` because watchdog functionality is not
    wanted in the recovery system because we do not want any automated reboot
    functionality while disaster recovery happens via "rear recover", see
    [PR 2808](https://github.com/rear/rear/pull/2808). Furthermore having a copy of
    `dev/watchdog*` during "rear mkrescue" in ReaR's build area may even trigger
    a **system crash** that is caused by a buggy TrendMicro ds_am module touching
    dev/watchdog in ReaR's build area (/var/tmp/rear.XXX/rootfs), see
    [issue 22798](https://github.com/rear/rear/issues/2798)

-   In _output/default/940_grub2_rescue.sh_ for GRUB_RESCUE set `root=/dev/ram0 vga=normal rw`
    (the same is already done for other boot media) to avoid a
    "Kernel panic ... Unable to mount root fs on unknown-block(0,0)" that could
    otherwise happen in certain cases, see
    [issue 2791](https://github.com/rear/rear/pull/2791)

-   In _build/GNU/Linux/400_copy_modules.sh_ always include loaded kernel
    modules i.e. also for `MODULES=()` or `MODULES=( 'moduleX' 'moduleY' )`
    include the currently loaded kernel modules,
    cf. [comment of issue 2727](https://github.com/rear/rear/issues/2727#issuecomment-994731345)

-   In _layout/save/GNU/Linux/200_partition_layout.sh_ ensure `$disk_label` is one
    of the supported partition tables (i.e. one of 'msdos' 'gpt'
    'gpt_sync_mbr' 'dasd') and ensure syntactically correct 'disk' and 'part'
    entries in disklayout.conf (each value must exist and each value must be a
    single non-blank word), see the last part about "error out directly ... when
    things failed" in [issue 28010](https://github.com/rear/rear/issues/2801#issuecomment-1122015129).
    But, do not error out when there is no partition label type value for a 'disk'
    entry in disklayout.conf, because "rear recover" works in a special case
    without partition label type value when there is only a 'disk' entry but
    nothing else for this disk exists in disklayout.conf which can happen when
    /dev/sdX is an empty SD card slot without medium, see
    [issue 2810](https://github.com/rear/rear/issues/2810)

-   In default.conf explain how to use LIBS properly, see
    [issue 2743](https://github.com/rear/rear/issues/2743)

-   In the function **find_syslinux_modules_dir** in _lib/bootloader-functions.sh_
    the fallback 'find /usr' to find the SYSLINUX modules directory may take a
    very long time on some systems (up to several hours) so tell the user in
    debug mode what is going on, see [issue 2792](https://github.com/rear/rear/issues/2792)
    and [issue 624](https://github.com/rear/rear/issues/624)

-   In default.conf tell that `MODULES=( 'loaded_modules' 'additional_module' )`
    is not supported (the generic `COPY_AS_IS` method can be used to include
    additional modules) cf. [issue 2727](https://github.com/rear/rear/issues/2727)

-   Use _disklayout.conf_ keyword **raidarray** instead of **raid** because we have
    a new 'raiddisk' keyword and a keyword must not be a leading substring of
    another keyword so we have now 'raidarray' and 'raiddisk', see
    [issue 2759](https://github.com/rear/rear/issues/2759) and
    [commit](https://github.com/rear/rear/commit/53757eab1447c712fb7c8e44be9c8b3b3ffd9faa)

-   In _layout/save/default/450_check_bootloader_files.sh_ use `/[e]tc/grub.cfg`
    and `/[b]oot/.../grub.cfg` with '*' globbing patterns (as in the EFI|GRUB2-EFI
    case) to find any of grub.cgf or grub2.cfg in /etc/ or in /boot/ (e.g. in
    openSUSE Leap 15.3 there is /boot/grub2/grub.cfg),
    cf. [issue 2796 comment](https://github.com/rear/rear/pull/2796#issuecomment-1118387393)

-   In default.conf added '[e]tc/crypttab' to FILES_TO_PATCH_PATTERNS,
    cf. [issue 2795 comment](https://github.com/rear/rear/pull/2795#discussion_r859670066)

-   New FILES_TO_PATCH_PATTERNS in default.conf to verify file hashes at the
    end of recover after file restore from backup and show an error when
    config files were restored from an outdated backup so the restored files
    do not match the recreated system, see
    [PR 2795](https://github.com/rear/rear/pull/2795) and
    [issue 2785](https://github.com/rear/rear/issues/2785) and
    [issue 2787](https://github.com/rear/rear/issues/2787)

-   In backup/RSYNC/default/450_calculate_req_space.sh comment out remote
    space check with rsync see [issue 2760](https://github.com/rear/rear/issues/2760)

-   In layout/save/default/450_check_bootloader_files.sh and
    layout/save/default/450_check_network_files.sh added bash globbing
    characters [] around the first letter to ensure that with 'shopt -s
    nullglob' files that do not exist will not appear so nonexistent files are
    not appended to CHECK_CONFIG_FILES
    cf. [issue 2796 comment](https://github.com/rear/rear/pull/2796#issuecomment-1117171070)

-   In backup/DUPLICITY/default/500_make_duplicity_backup.sh disable SC2068
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In backup/YUM/default/500_make_backup.sh and
    backup/NETFS/default/500_make_backup.sh and
    prep/NETFS/default/070_set_backup_archive.sh fixed SC2068
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In rescue/default/850_save_sysfs_uefi_vars.sh disable SC2045
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In layout/save/GNU/Linux/240_swaps_layout.sh and lib/output-functions.sh
    fixed SC2045 cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In lib/_input-output-functions.sh disable SC2218
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In layout/save/GNU/Linux/230_filesystem_layout.sh aviod SC1087
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In default.conf tell that USB_RETAIN_BACKUP_NR is only supported when
    EXTLINUX is used as bootloader for USB and in
    output/USB/Linux-i386/300_create_extlinux.sh add an explanatory comment
    how that code works,
    cf. [issue 2794 comment](https://github.com/rear/rear/pull/2794#issuecomment-1106286485)

-   In layout/save/GNU/Linux/210_raid_layout.sh fixed and overhauled the
    RAID10 'layout' support code (i.e. what belongs to the mdadm -layout
    option). This was triggered by ShellCheck SC2034 and SC2066 for the old
    code, see [issue 2758](https://github.com/rear/rear/pull/2768)

-   In finalize/Fedora/i386/550_rebuild_initramfs.sh fixed SC2068 and SC2145
    via some generic code cleanup
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160) and
    see [issue 2771](https://github.com/rear/rear/pull/2771)

-   In rescue/GNU/Linux/310_network_devices.sh fix SC2091 see
    [issue 2776](https://github.com/rear/rear/pull/2776)

-   In default.conf increase USB_UEFI_PART_SIZE to 1024 MiB,
    cf. https://github.com/rear/rear/pull/1205 in particular to also make
    things work by default when additional third-party kernel modules and
    firmware (e.g. from Nvidia) are used,
    cf. [issue 2770 comment](https://github.com/rear/rear/issues/2770#issuecomment-1068935688)

-   In doc/rear.8 and doc/rear.8.adoc fixed typo '/dev/disk/by-path/REAR-000'
    -> '/dev/disk/by-label/REAR-000'

-   In default.conf better describe USB_DEVICE
    cf. [issue 2770 comment](https://github.com/rear/rear/issues/2770#issuecomment-1068831482)

-   In output/default/940_grub_rescue.sh removed a misleading comment that
    shows a wrong get_version function call and in
    output/USB/Linux-i386/850_make_USB_bootable.sh fixed a wrong get_version
    function call that is needed since the ShellCheck SC2068 fixed get_version
    function in lib/layout-functions.sh

-   In layout/recreate/default/120_confirm_wipedisk_disks.sh and
    layout/prepare/Linux-s390/205_s390_enable_disk.sh and
    rescue/GNU/Linux/310_network_devices.sh and
    rescue/GNU/Linux/230_storage_and_network_modules.sh and
    restore/default/990_move_away_restored_files.sh and
    restore/NBU/default/300_create_nbu_restore_fs_list.sh and
    skel/default/etc/scripts/system-setup.d/00-functions.sh and
    skel/default/etc/scripts/dhcp-setup-functions.sh and
    wrapup/default/990_copy_logfile.sh and
    usr/share/rear/lib/output-functions.sh and lib/layout-functions.sh and
    lib/filesystems-functions.sh and lib/linux-functions.sh avoid ShellCheck
    SC2068
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In output/ISO/Linux-i386/800_create_isofs.sh avoid ShellCheck SC2068 and
    SC2145
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In output/TSM/default/960_dsmc_verify_isofile.sh avoid ShellCheck SC2068
    and SC2145
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160) plus
    better error checking and messaging and other code cleanup

-   In output/default/940_grub2_rescue.sh and
    output/default/940_grub_rescue.sh avoid ShellCheck SC2068
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In output/default/950_email_result_files.sh avoid ShellCheck SC2068 and
    SC2145
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160) and
    replaced ...IfError function calls by calling Error

-   In restore/FDRUPSTREAM/default/260_copy_log_and_report.sh fixed ShellCheck
    reported error SC2199
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160) and
    fixed possible "bash: conditional binary operator expected" error

-   In output/USB/Linux-i386/300_create_extlinux.sh and
    rescue/GNU/Linux/310_network_devices.sh avoid ShellCheck reported error
    SC2199
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In prep/NBKDC/default/400_prep_nbkdc.s and lib/sesam-functions.sh avoid
    ShellCheck false error indication SC1097
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In lib/_input-output-functions.sh fixed ShellCheck reported errors SC2145
    and SC2068 and avoided ShellCheck false error indication SC1087
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062945160)

-   In usr/sbin/rear avoid ShellCheck SC1075 and fixed ShellCheck SC2145
    cf. [issue 1040](https://github.com/rear/rear/issues/1040)

-   In output/RAWDISK/Linux-i386/260_create_syslinux_efi_bootloader.sh fixed
    ShellCheck SC2235
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In rear/lib/sesam-functions.sh fixed ShellCheck SC2221
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In lib/filesystems-functions.sh in function xfs_parse fixed ShellCheck
    SC2179 and SC2128
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)
    furthermore 'xfs_opts' is local in both functions xfs_parse and create_fs
    in layout/prepare/GNU/Linux/131_include_filesystem_code.sh

-   In lib/layout-functions.sh fixed ShellCheck SC2178
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In skel/default/etc/scripts/system-setup.d/00-functions.sh ignore
    ShellCheck SC2119 and SC2120
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1062703092)

-   In restore/DUPLICITY/default/150_restore_duply.sh avoid ShellCheck SC2103
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In layout/prepare/GNU/Linux/100_include_partition_code.sh fixed ShellCheck
    SC2199 and SC2076
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In output/ISO/Linux-ia64/400_create_local_efi_dir.sh fixed ShellCheck
    SC2050
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In layout/save/GNU/Linux/230_filesystem_layout.sh fixed ShellCheck SC2030
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In verify/NBU/default/380_request_client_destination.sh fixed ShellCheck
    SC2018 and SC2019
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   In backup/YUM/default/500_make_backup.sh fixed ShellCheck SC2000
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034870262)

-   Simpler code in prep/Linux-s390/305_include_s390_tools.sh to set a fixed
    bootdir="/boot" that also fixes ShellCheck SC1066
    cf. [issue 1040 comment](https://github.com/rear/rear/issues/1040#issuecomment-1034890880)

-   New GRUB2_SEARCH_ROOT_COMMAND in default.conf to overrule the setting in
    output/USB/Linux-i386/100_create_efiboot.sh see
    [issue 2763](https://github.com/rear/rear/pull/2763) and
    [issue 2500](https://github.com/rear/rear/issues/2500)

-   New EXCLUDE_IP_ADDRESSES and EXCLUDE_NETWORK_INTERFACES directives: These
    new array variables enable to exclude specific IP addresses or network
    interfaces when building the network configuration used in the rescue
    environment. This is typically useful when floating IP addresses are used.
    Not excluding these may lead to outage if the floating IP address is used
    by another system at time the system is getting recovered, see
    [issue 2736](https://github.com/rear/rear/pull/2736)

-   multipath: fix exclusion of still wanted devices: The current code
    excluding multipath devices is broken when a device being excluded matches
    other devices. This leads to excluding wanted devices. This happens when
    having custom alias for multipath devices or there are more than 26
    multipath devices and 'mpatha' is getting excluded, which leads to
    excluding all 'mpathaX' devices are well, see
    [issue 2750](https://github.com/rear/rear/pull/2750)

-   Update 06-layout-configuration.adoc: Enhance the "disk layout file syntax"
    description: Describe that one cannot rely on backward compatibility.
    Describe positional parameters vs. option=value parameters.

-   Update default.conf: In default.conf describe that when OUTPUT_URL is set
    OUTPUT_OPTIONS does not inherit the BACKUP_OPTIONS value
    cf. [issue 2753](https://github.com/rear/rear/issues/2753)

-   Include dmsetup and dmeventd as PROGS in conf/GNU/Linux.conf because older
    releases of os-prober (1.74 and below) use dmsetup as a fallback solution
    for mounting when grub-mount is missing but without dmsetup and dmeventd
    also in the recovery system that would block indefinitely at "Installing
    GRUB2 boot loader...", for details see
    [issue 2748](https://github.com/rear/rear/pull/2748)

-   In the function cmdline_add_console in lib/serial-functions.sh add
    'console=tty0' as fallback to cmdline only if no real serial device was
    found otherwise on a machine with e.g. ttyS0 and ttyS1 where only ttyS0 is
    real only kernel messages (but nothing else) would appear on ttyS0, see
    [issue 2749](https://github.com/rear/rear/pull/2749)

-   Skip unneeded /usr/lib/syslog-ng/loggen/ from recovery system: In
    conf/GNU/Linux.conf do no longer copy all in /usr/lib/syslog-ng/ but only
    copy .so files in /usr/lib/syslog-ng/ (same as for rsyslog). This skips in
    particular /usr/lib*/syslog-ng/loggen/ because 'loggen' is not included in
    the recovery system ('loggen' does not appear in any ReaR code). See
    [issue 2743](https://github.com/rear/rear/issues/2743)

-   For BACKUP=CDM removed need for the whole /usr/lib64 in the recovery
    system. See [issue 2747](https://github.com/rear/rear/pull/2747) and the related issues
    [2266](https://github.com/rear/rear/issues/2266), 
    [2314](https://github.com/rear/rear/issues/2314), 
    [2685](https://github.com/rear/rear/issues/2685)' and 
    [issue 2700](https://github.com/rear/rear/issues/2700)

-   Update 400_copy_modules.sh: Do no longer error out if 'cp -a -L' failed to
    to copy all contents of /lib/modules/... but only tell the user about the
    issue so he could inspect his system and decide, see
    [issue 2739 comment](https://github.com/rear/rear/issues/2739#issuecomment-1014304127)

-   Support for HTTP sources when using PXE: There is a new config variable
    PXE_HTTP_URL to specify the HTTP download source for PXE. If the variable
    is set the PXE config file will generate an additional 3rd boot option
    (besides the unchanged standard options "rear" via TFTP and "local")
    namely "rear-http" which includes the HTTP URL information to download the
    kernel and initrd data. See [issue 2738](https://github.com/rear/rear/pull/2738)

-   Also add ssh-add prog when ssh-agent is added. Since ssh-agent gets added
    it makes sense to add ssh-add as well. See
    [PR 2729 ](https://github.com/rear/rear/pull/2729)

-   In layout/prepare/default/420_autoresize_last_partitions.sh automatically
    resize active last partitions on RAID0 disks, see
    [issue 2696](https://github.com/rear/rear/issues/2696). Therefore in
    `layout/save/GNU/Linux/210_raid_layout.sh` a new 'raiddisk' entry that has
    same syntax as a 'disk' entry is written to disklayout.conf to have size
    (and partition label) of a RAID device like `raiddisk /dev/md127 23599054848 gpt`
    because knowing the RAID device size is a precondition to
    be able to automatically resize a RAID0 array. See
    [issue 2730](https://github.com/rear/rear/pull/2730)

-   In layout/prepare/default/420_autoresize_last_partitions.sh automatically
    resize active last partitions on RAID1 disks and fixed fallback setting so
    that now the user can specify AUTORESIZE_EXCLUDE_PARTITIONS=() in his
    local.conf. Additionally in layout/prepare/default/250_compare_disks.sh
    show info about old disk and sizes and new disks and sizes in case of
    MIGRATION_MODE to make it easier to answer the questions to which new
    disks old disk should be mapped. See
    [PR 2726](https://github.com/rear/rear/pull/2726)

-   Fix modinfo_filename() in build/GNU/Linux/400_copy_modules.sh Output the
    original $module_filename also when it is a symlink because in the code
    below 'cp -L' copies the symlink taget content as a new regular file with
    file name as the name of the symlink so the copied content can be still
    found under its original name, cf.
    [issue 2677 comment](https://github.com/rear/rear/issues/2677#issuecomment-997859219)
    Additionally in case of MODULES=( 'all_modules' ) also use 'cp -L' to copy
    the actual content to avoid dangling symlinks in the recovery system. See
    [PR 2731](https://github.com/rear/rear/pull/2731)

-   In usr/share/rear/output/PXE/default/800_copy_to_tftp.sh fixed pxe file cp
    and permissions for sshfs target to prevent cp error "failed to preserve
    ownership" for sshfs and to prevent issue with write permissions trying to
    override image on later runs. See [issue 2723](https://github.com/rear/rear/pull/2723)

-   Improved wiping disks (see [PR 2721](https://github.com/rear/rear/pull/2721)): In
    layout/recreate/default/120_confirm_wipedisk_disks.sh skip disks that do
    not exist on the bare hardware in the recovery system
    cf. [issue 2715](https://github.com/rear/rear/issues/2715) and exclude disks that are
    write-protected
    cf. [issue 2703 comment](https://github.com/rear/rear/pull/2703#issuecomment-979928423) and show
    in any case a user confirmation dialog for the disks that will be wiped.
    In layout/recreate/default/150_wipe_disks.sh do no longer open (and close)
    LUKS volumes because encrypted volumes contain meaningless data unless
    opened and unencrypted so there is no need to wipe anything inside an
    encrypted LUKS container, cf. "Regarding LUKS" in
    [issue 2514 comment](https://github.com/rear/rear/pull/2514#issuecomment-743483945)

-   Overhauled RAID code (see [PR 2714](https://github.com/rear/rear/pull/2714)) based on
    https://github.com/rear/rear/pull/2702 that is about initial software RAID
    IMSM support i.e. with the changes in that pull request: Completely
    overhauled layout/save/GNU/Linux/210_raid_layout.sh: No longer a subshell
    that appends all stdout to disklayout.conf but explicit append to
    disklayout.conf where needed to be safe against accidental things written
    to disklayout.conf. Handle each mdadm option in one place i.e. parse and
    prepare output. Handle options ordered by importance, mandatory first,
    then optional ones. Basic tests that mandatory options are syntactically
    valid plus Error if not. Overhauled
    layout/prepare/GNU/Linux/120_include_raid_code.sh: The `FEATURE_MDADM_UUID`
    code is meanwhile obsolete because all mdadm versions in supported ReaR
    Linux distributions support '-uuid'. New
    layout/recreate/default/220_verify_layout.sh to verify if RAID devices are
    recreated with the UUIDs in disklayout.conf because mdadm silently ignores
    this option when creating IMSM arrays (both containers and the volumes
    inside them) and picks a random UUID
    cf. [issue 2701 comment](https://github.com/rear/rear/pull/2702#issuecomment-970395567)
    Support user specified DISKS_TO_BE_WIPED to mitigate
    [issue 2715](https://github.com/rear/rear/issues/2715) see the `DISKS_TO_BE_WIPED`
    description in default.conf

-   Update 100_create_layout_file.sh: Additionally show the filesystem LABEL
    in the 'lsblk' output of the original system as comment in disklayout.conf
    to make it easier to understand subsequent data in particular for RAID
    where the array name is shown as LABEL in 'lsblk' for example like
    "/dev/sda ... linux_raid_member any:raid1sdab" - see also "one cannot see ...
    /dev/md/ symlinks as NAME ... /dev/md/raid1sdab -> ../md127" in
    [PR 2702 comment](https://github.com/rear/rear/pull/2702#issuecomment-951769031) and see also
    [commit](https://github.com/rear/rear/commit/1a8a88c20d01f01fac65e296e9481ab9172c3ac7)

-   Update 100_create_layout_file.sh: Additionally show UUID in 'lsblk' output
    of the original system as comment in disklayout.conf to make it easier to
    compare UUIDs of the original system with what was recreated, cf. "...
    shouldn't it [ReaR] restore the [RAID] arrays with the same UUIDs ...?" in
    https://github.com/rear/rear/pull/2702#issuecomment-968904230 and
    https://github.com/rear/rear/pull/2714#issuecomment-970279152

-   Update 050_start_required_nfs_daemons.sh: Start rpcbind with the -s option
    to avoid that in some cases rpcbind is not started / not available in the
    recovery system cf. https://github.com/rear/rear/issues/2672

-   New function is_multipath_used in layout-functions.sh (see
    https://github.com/rear/rear/pull/2708) to get 'multipath -l' out of the
    function is_multipath_path by adding a separated function
    is_multipath_used that runs 'multipath -l' (which is expensive because it
    scans all devices) to check if multipath is used and remembers the result
    in MULTIPATH_IS_USED that is used in subsequent calls of is_multipath_used
    (without calling 'multipath -l') so we can call is_multipath_used many
    times via is_multipath_path which is called in
    layout/save/GNU/Linux/200_partition_layout.sh for each disk device. This
    should avoid long computing time when there are very may disk devices,
    cf. https://github.com/rear/rear/pull/2597#issuecomment-814950019

-   Now "rear format" has in addition to the -efi switch a -bios switch. If
    none is given (i.e. by default) it will now do hybrid formatting with a
    BIOS boot partition (on GPT) and an EFI system partition. This is a
    starting point for implementing OUTPUT=USB support for UEFI and BIOS dual
    boot from the same medium see https://github.com/rear/rear/issues/2698 and
    https://github.com/rear/rear/pull/2705

-   Update write-protect-functions.sh: In the function
    is_write_protected_by_id() assume a disk without any of UUID PTUUID
    PARTUUID WWN is empty and meant to be used to recreate the system so it
    should not be write-protected
    cf. https://github.com/rear/rear/pull/2703#discussion_r757393547

-   Enhanced disk write-protection, see https://github.com/rear/rear/pull/2703
    and https://github.com/rear/rear/pull/2626 by WRITE_PROTECTED_IDS with
    generic functionality,
    cf. https://github.com/rear/rear/pull/2626#issuecomment-950953826 together
    with the new WRITE_PROTECTED_ID_TYPES which defaults to UUID PTUUID
    PARTUUID WWN so that the user can specify different lsblk columns as
    needed in his particular environment
    cf. https://github.com/rear/rear/pull/2703#issuecomment-962418441

-   Stop ReaR from overwriting its own disk and backup drives for OUTPUT=USB
    and OUTPUT=RAWDISK via new WRITE_PROTECTED_... config variables (see
    default.conf) where UUIDs or filesystem labels can be specified so that
    disks that contain such UUIDs or filesystem labels will be 'write
    protected' during "rear recover", see
    https://github.com/rear/rear/issues/1271 and
    https://github.com/rear/rear/pull/2626

-   Overhauled serial console support code. See
    https://github.com/rear/rear/pull/2699 A serial console of the ReaR
    recovery system can now be specified separately for the kernel and the
    recovery system bootloader via the generic config variables
    USE_SERIAL_CONSOLE and SERIAL_CONSOLE_DEVICES and specific config
    variables SERIAL_CONSOLE_DEVICES_KERNEL SERIAL_CONSOLE_DEVICE_SYSLINUX
    SERIAL_CONSOLE_DEVICE_GRUB see usr/share/rear/conf/default.conf for
    details cf. https://github.com/rear/rear/issues/2663 and
    https://github.com/rear/rear/pull/2697

-   More control over serial devices used for console. See
    https://github.com/rear/rear/pull/2697

-   In layout/prepare/default/300_map_disks.sh overhauled the automapping of
    original 'disk' devices and 'multipath' devices to current block devices
    in the currently running recovery system so that now it automatically
    finds an existing unique disk size mapping also when there is a unique
    mapping between more than two disks, see
    https://github.com/rear/rear/issues/2690

-   Fix multiple VG recreation, see https://github.com/rear/rear/pull/2691 Do
    not use global variables in diskrestore.sh: Fix a problem introduced in
    commits b184194f37dd22a7e55655ff388579297239e73c and
    311bfb3da1d5e47a2ff144123a2457e634f67893 (PR #1806) that shows up when
    there are multiple VGs to restore. Using variables
    create_thin_volumes_only and create_logical_volumes to propagate
    information from VG creation to LV creation does not work well in the case
    of multiple VGs, because the variables are global and if there are
    multiple VGs, their values will leak from one VG to another. The generated
    diskrestore.sh script does not guarantee that the LVs of a given VG are
    created immediately after their VG and before creating another VG.
    Currently, the script first creates all VGs and then all LVs, so all the
    LVs in all VGs will see the value of create_logical_volumes and
    create_thin_volumes_only from the last VG, not from their own. This
    matters when different VGs behave differently (typically if one has a thin
    pool and the other does not). Fix by replacing the scalar values by arrays
    of VG names. If a given VG is in the array, it is the equivalent of the
    former scalar value being 1 for the given VG, if it is not in the array,
    it is an equivalent of a former value of 0. For the create_volume_group
    variable the change is not needed, but do it nevertheless for symmetry
    with other variables.

-   Error out in sbin/rear when it failed to source or Source() mandatory
    files to make it obvious when there are syntax errors in user config files
    and/or when there are syntax errors in our lib/*-functions.sh code, see
    https://github.com/rear/rear/issues/2686

-   Overhauled output/USB/Linux-i386/100_create_efiboot.sh In particular no
    longer use "cp -p" because '-p' may fail because it copies to a VFAT
    filesystem on the EFI partition see
    https://github.com/rear/rear/issues/2683 and now always use "cp -L" to
    ensure the real content gets copied. See
    https://github.com/rear/rear/pull/2684

-   Overhauled the description in user-guide/05-integration.adoc what "rear
    savelayout" and "rear checklayout" are menat to do, cf.
    https://github.com/rear/rear/commit/7a3884bed1fb6cb61654c4e266ba4c35094bd9f4#r56879062

-   Fixed https://github.com/rear/rear/issues/2667 "rear does not entirely
    remove build area any more" by using double quotes for
    remove_temporary_mountpoint "$BUILD_DIR/..." and fixed
    https://github.com/rear/rear/issues/2676 "False ERROR '.../outputfs not
    empty, cannot remove' when OUTPUT_URL is unset" by making
    scheme_supports_filesystem() fail-safe if $1 is empty or blank and also
    making scheme_accepts_files() fail-safe in the same way, see
    https://github.com/rear/rear/pull/2675

-   On POWER require bootlist & ofpathname if needed: The ofpathname binary is
    called by grub2-install. Therefore, it is required in the rescue system in
    order to make the recovered system bootable, except for the PowerNV (Not
    Virtualized - bare metal) case. Under PowerVM, we also need the bootlist
    executable to make the system bootable. See
    https://github.com/rear/rear/pull/2665

-   ReaR's default TMPDIR is now /var/tmp (it was /tmp before) i.e. ReaR's
    default working area is now /var/tmp/rear.XXXXX ReaR needs lots of space
    (from 300MB up to more than 1GB) to build the ReaR rescue/recovery system
    e.g. as ISO image and even much more space to also store the backup
    archive e.g. when the backup should be included in the ISO image. The
    system's default temporary directory /tmp is no longer suited as default
    temporary directory for ReaR because nowadays /tmp is often a "tmpfs" that
    is in RAM so /tmp has RAM/swap limitations. file-hierarchy(7) recommends
    to use /var/tmp for such cases. If the user sets TMPDIR explicitly, it
    still takes precedence. See https://github.com/rear/rear/pull/2664

-   Cleanup of GRUB2 config code in particular for OUTPUT=USB: Cleanup of the
    create_grub2_cfg function: Describe its usage in a comment. Have its
    helper functions inside create_grub2_cfg to make them not globally
    accessible. Initial steps to clean up how the GRUB root device is set via
    one single method. DebugPrint output how GRUB2 is configured to help the
    user to find errors or bugs. Better GRUB2 menue entry names. Consistent
    calling of the create_grub2_cfg function always as create_grub2_cfg
    "/path/to/kernel" "/path/to/initrd" >/path/to/grub.cfg also in
    output/ISO/Linux-i386/250_populate_efibootimg.sh. Set GRUB2 timeout to new
    config variable GRUB2_TIMEOUT that is by default 300 seconds. Set GRUB2
    default boot menu entry to GRUB2_DEFAULT_BOOT that is by default
    'chainloader' which should usually boot the original system and reference
    GRUB2 boot menu entries by 'menuentry ... -id=...' to have meaningful names
    instead of meaningless numbers. Sleep 3 seconds exactly before GRUB2 shows
    its menu (it replaces what there is on the screen) so that the user could
    see possible GRUB2 (error) messages on the screen. Additionally cleanup of
    the get_root_disk_UUID function. See
    https://github.com/rear/rear/pull/2662

-   Fixed serial console for syslinux: It writes only one serial line matching
    the configured device (when found) to the config. It also writes it for
    the syslinux config in case it is used without extlinux. See
    https://github.com/rear/rear/pull/2650

-   Fix function create_grub2_cfg() for the none EFI cases and adds serial
    console configuration to the GRUB2 config. See
    https://github.com/rear/rear/pull/2661

-   Simplifications for USB_BOOTLOADER="grub" and choose the right GRUB2
    config /boot/grub/grub.cfg or /boot/grub2/grub.cfg see
    https://github.com/rear/rear/pull/2659

-   Cleanup USB format scripts and related code: Now OUTPUT=USB should behave
    sufficiently OK on BIOS systems with syslinux/extlinux as bootloader with
    a separated boot partition and without it (still the default). To use
    OUTPUT=USB on BIOS with syslinux/extlinux with a separated boot partition
    size of e.g. 1024 MiB specify in etc/rear/local.conf something like
    OUTPUT=USB USB_BOOT_PART_SIZE=1024
    OUTPUT_URL=usb:///dev/disk/by-label/REARBOOT BACKUP=NETFS
    BACKUP_URL=usb:///dev/disk/by-label/REAR-000 See
    https://github.com/rear/rear/pull/2660

-   Fixed format/USB/default/300_format_usb_disk.sh for none EFI cases by
    adding a BIOS boot partition and setting the 'legacy_boot' flag in case of
    GPT partitioning. See https://github.com/rear/rear/pull/2656

-   Added support for GRUB2 as bootloader for OUTPUT=USB via new config
    variable USB_BOOTLOADER=grub see https://github.com/rear/rear/pull/2655

-   With the new default USER_INPUT_MAX_CHARS=0 input is not truncated and it
    also makes correcting the input possible (before [Enter] is pressed) see
    https://github.com/rear/rear/issues/2622

-   Update default.conf: Since https://github.com/rear/rear/pull/2633 export
    TMPDIR="..." in ReaR config files like etc/rear/local.conf does no longer
    work so now export TMPDIR="..." must be called before calling 'rear'
    cf. https://github.com/rear/rear/issues/2654

-   Treat RAID layout value '-unknown-' same as an empty value: In
    layout/save/GNU/Linux/210_raid_layout.sh treat the RAID layout value
    '-unknown-' same as an empty value to avoid that
    layout/prepare/GNU/Linux/120_include_raid_code.sh will create a 'mdadm'
    command in diskrestore.sh like "mdadm ... -layout=-unknown- ..." which would
    fail during "rear recover" with something like "mdadm: layout -unknown-
    not understood for raid0", see https://github.com/rear/rear/issues/2616

-   Avoid false Error() exit in copy_binaries() in
    build/GNU/Linux/390_copy_binaries_libraries.sh by skipping 'cp' errors in
    copy_binaries() (regardless what the reason was why 'cp' failed) but then
    add the affected binary to REQUIRED_PROGS to verify later that the binary
    actually exists in the recovery system which should be still sufficient to
    let ReaR error out if something actually went wrong with needed binaries.
    See https://github.com/rear/rear/pull/2643

-   NSR enhancement for point-in-time recovery with EMC Networker client: A
    new variable NSR_CLIENT_REQUESTRESTORE for the BACKUP=NSR workflow has
    been introduced to deal with situations in which the NSR client is
    allowed/granted to perform its recovery action "on its own" but does not
    have full control of the EMC networker service/environment, for details
    see its default.conf section. See https://github.com/rear/rear/pull/2641

-   Workaround against DRBD9 restore error "refusing to be primary while peer
    is not outdated" see https://github.com/rear/rear/issues/2634

-   Cleanup rsync and fix error reporting: See
    https://github.com/rear/rear/pull/2632 Cleanups of rsync code to use
    better variable names and local variables, stop using StopIfError, use
    better redirections etc. Fixed a problem with rsync error detection that
    caused rsync errors during backup restore to be ignored, see
    https://github.com/rear/rear/issues/2612 Now a warning is displayed and if
    BACKUP_INTEGRITY_CHECK is true, it is elevated to an error and ReaR
    aborts. Furthermore check fake super support only when RSYNC_PROTO=ssh and
    removed a broken test for -fake-super arg to rsync, cf.
    https://github.com/rear/rear/pull/2577

-   Show some stdout and stderr messages also in non-debug modes: In non-debug
    modes (in particular also in verbose mode) stdout and stderr are
    redirected to a temporary file
    STDOUT_STDERR_FILE=TMP_DIR/rear.WORKFLOW.stdout_stderr so in non-debug
    modes stdout and stderr of all programs is still available for the Error()
    function to extract some latest messages that get shown on the usrer's
    terminal and those extracted lines are also copied into the log
    cf. https://github.com/rear/rear/issues/2623 and
    https://github.com/rear/rear/issues/2416 and
    https://github.com/rear/rear/pull/2498 Furthermore the log files and the
    stdout/stderr file can now only be read by root. Additionally when there
    is something still mounted within the build area when rear finishes, the
    user is informed what is mounted and that he must manually umount it
    before he can (also manually) remove the build area. Finally the Error()
    and cleanup_build_area_and_end_program() functions are made fail-safe
    against not yet existing log files and not yet sourced other functions in
    case of early Error() exits in usr/sbin/rear see
    https://github.com/rear/rear/pull/2633

-   Fixed accidental destructive backup removal in exit task and cleanup
    handling of URL mountpoints: See https://github.com/rear/rear/pull/2625
    Cleanup of temporary mount point handling, particularly for output.
    Unification of mount point umount and cleanup move to the mount_url() and
    umount_url() functions. Replaced the various "rm -rf" of the mountpoint by
    "rmdir" which fixes https://github.com/rear/rear/issues/2611 Added lazy
    umount in case normal umount does not succeed. If build dir is kept
    (cf. KEEP_BUILD_DIR), propose a safe way to remove it to the user via "rm
    -Rf -one-file-system" instead of just "rm -Rf" where the user risks to
    remove everything below that mountpoint if still mounted. Fixes also some
    other bugs noted in the process: Filesystem-specific umount command not
    called
    https://github.com/rear/rear/commit/20359a987662cc0c3fcfa52d62d1feac7cd55850#r51319634
    Unknown schemes considered invalid, see the discussion under
    https://github.com/rear/rear/pull/932 Identical scripts under DUPLICITY
    and YUM replaced by symlinks. Reverted
    https://github.com/rear/rear/pull/782 that had reintroduced
    https://github.com/rear/rear/issues/465 which got re-reported as
    https://github.com/rear/rear/issues/2611 Reverted
    https://github.com/rear/rear/pull/578 because it is not clear how
    .lockfile can exist in the unmounted filesystem, and if it does, it is a
    bug. Reverted
    https://github.com/rear/rear/commit/d850c4094238a03c9b926b88d7e1582ecd28af52
    because it became meanwhile obsoleted by
    https://github.com/rear/rear/commit/a8fdc445d0d6f7f9184dc6633817928f96aae9bc

-   Add BACKUP_DUPLICITY_OPTIONS to
    restore/DUPLICITY/default/400_restore_duplicity.sh Additionnal
    BACKUP_DUPLICITY_OPTIONS options were missing which can cause the recover
    to fail (options may contain endpoint information for example), see
    https://github.com/rear/rear/issues/2619

-   In prep/default/400_save_directories.sh also exclude mountpoints that are
    below mountpoints of "type autofs": Those are below an ancestor mountpoint
    that is owned/created by the automounter. It is possible to create a
    sub-mountpoint below an automounted mountpoint but the fact that the
    sub-mountpoint is not local means it should be excluded (i.e. there is no
    need to recreate the non-local sub-mountpoint directory), see
    https://github.com/rear/rear/issues/2610

-   Better description and error checking for GRUB_RESCUE with UEFI plus some
    alignment with the create_grub2_cfg function,
    cf. https://github.com/rear/rear/issues/2545 Better describe GRUB_RESCUE
    with UEFI in default.conf and in output/default/940_grub2_rescue.sh better
    error checking plus some alignment with how create_grub2_cfg() creates a
    GRUB2 config file i.e. no longer "insmod" the GRUB2 modules efi_gop
    efi_uga video_bochs video_cirrus
    cf. https://github.com/rear/rear/pull/2609#issuecomment-831883795 and the
    discussion in https://github.com/rear/rear/issues/2388 see
    https://github.com/rear/rear/pull/2609

-   Fix setting boot path in case of UEFI partition (ESP) on MD RAID: The code
    finalize/Linux-i386/670_run_efibootmgr.sh did not support Software RAID.
    It has to execute the efibootmgr command on the members of the Software
    RAID, see https://github.com/rear/rear/issues/2595 The ESP may be located
    on a RAID device. In this case, we need to determine the physical RAID
    components and call efibootmgr on them. In addition, clean up
    finalize/Linux-i386/670_run_efibootmgr.sh and add more logging to ease
    analysis when something goes wrong, see
    https://github.com/rear/rear/pull/2608

-   In prep/RSYNC/default/050_prep_rsync.sh adding sleep period to give rsync
    daemon time to wake up, see https://github.com/rear/rear/pull/2599

-   Have unused LVM PV devices only as comment in disklayout.conf: PVs that
    are not part of a VG are documented as comment in disklayout.conf but they
    are not recreated because they were not used on the original system so
    there is no need to recreate them by "rear recover" see
    https://github.com/rear/rear/issues/2596 and
    https://github.com/rear/rear/pull/2603

-   Automatically shrink LVs if needed during "rear recover". This enables to
    run "rear recover" with automated LVM LVs shrinking as needed on a bit
    smaller replacement disk (e.g. when a nominally same sized replacement
    disk is actually a bit smaller than the original disk). This automated LVs
    shrinking is not intended when disk(s) are substantially smaller. To
    migrate onto a substantially smaller replacement disk the user must in
    advance manually adapt his disklayout.conf file before he runs "rear
    recover". In layout/prepare/GNU/Linux/110_include_lvm_code.sh assume the
    command "lvcreate -L 123456b -n LV VG" had failed because of "Volume group
    ... has insufficient free space" and then try as fallback attempt using all
    remaining free space in the VG via "lvcreate -l 100%FREE -n LV VG". In
    layout/save/GNU/Linux/220_lvm_layout.sh sort the 'lvs' output lines by
    size of the LVs so only some biggest LVs may get automatically shrinked
    (if needed) because we assume that the data of the backup can still be
    restored into a big LV after it was shrinked a bit. See
    https://github.com/rear/rear/pull/2591

-   Replaced possibly misleading "USB device" by generic "USB or disk device"
    wording in user messages (e.g. when a built-in disk /dev/sdc is used that
    is no USB device). The word "USB" indicates that those messages belong to
    the OUTPUT=USB method,
    cf. https://github.com/rear/rear/pull/2589#issuecomment-805649510 and
    https://github.com/rear/rear/issues/2588 and
    https://github.com/rear/rear/pull/2589

-   Wipe disks before recreating partitions/volumes/filesystems/... see
    https://github.com/rear/rear/issues/799 See the new DISKS_TO_BE_WIPED in
    default.conf and for details see
    usr/share/rear/layout/recreate/default/README.wipe_disks This is currently
    new and experimental functionality so that currently by default via
    DISKS_TO_BE_WIPED='false' no disk is wiped to avoid possible regressions
    until this new feature was more tested by interested users via an explicit
    DISKS_TO_BE_WIPED setting in local.conf see
    https://github.com/rear/rear/pull/2514

-   In etc/scripts/system-setup.d/41-load-special-modules.sh load the nvram
    kernel module if possible to make /dev/nvram appear because /dev/nvram
    should be there when installing GRUB, see
    https://github.com/rear/rear/issues/2554 and include the nvram kernel
    module in the recovery system because nvram could be a module in
    particular on POWER architecture see
    https://github.com/rear/rear/issues/2554#issuecomment-764720180 and
    https://github.com/rear/rear/pull/2580

-   Make 400_copy_modules.sh fail-safe for newer modinfo output (in particular
    modinfo in kmod-27 since SLES15-SP3) because otherwise copying builtin
    kernel "modules" would let "rear mkrescue" error out with e.g. "ERROR:
    unix exists but no module file?". Furthermore ensure that kernel modules
    that should be loaded during recovery system startup (i.e. those in
    MODULES_LOAD) get always copied into the recovery system. See
    https://github.com/rear/rear/pull/2579

-   In 300_format_usb_disk.sh adapt USB_UEFI_PART_SIZE fallback value to 512
    to be in compliance with the new default.conf setting of 512 MiB since
    https://github.com/rear/rear/commit/9a6b9a109aa77afc6c96cf05bbd7988cf0310d61
    that was done in relation to https://github.com/rear/rear/pull/2576 see
    also https://github.com/rear/rear/issues/2602

-   Do not specify '-F 16' for mkfs.vfat and also no '-o fat=16' when mounting
    it but rely on the mkfs.vfat automatic FAT type selection (which is FAT16
    up to 511 MiB and FAT32 starting at 512 MiB at least on openSUSE Leap 15.2
    with mkfs.vfat from dosfstools-4.1) and rely on the automatic FAT type
    detection when mounting, cf. https://github.com/rear/rear/issues/2575 and
    increase the default ESP size to USB_UEFI_PART_SIZE="512" to get by
    default (via mkfs.vfat) a FAT32 ESP to be in compliance that "the ESP
    should officially use a FAT32 filesystem" to avoid possible FAT16 ESP
    issues with certain UEFI firmware. See
    https://github.com/rear/rear/pull/2576

-   Update 230_filesystem_layout.sh: Increase the 'docker info' timeout value
    from 5 seconds to 10 seconds because sometimes 'docker info' needs more
    than 5 seconds to finish,
    cf. https://github.com/rear/rear/pull/2572#issuecomment-784110872

-   Support loop devices in format_usb_disk see
    https://github.com/rear/rear/pull/2555

-   Update 110_include_lvm_code.sh: Make sure we delete the volume group
    before re-creating it. The issue happens in Migration mode when ReaR is
    not trying to use vgcfgrestore. See https://github.com/rear/rear/pull/2564

-   In usr/share/rear/output/ISO/Linux-i386/700_create_efibootimg.sh add 2
    more 32MiB blocks to be on the safe side against inexplicable failures
    like "cp: error writing
    '/tmp/rear.XXX/tmp/efi_virt/./EFI/BOOT/elilo.conf': No space left on
    device" where the above calculated $efi_img_sz is a bit too small in
    practice, see https://github.com/rear/rear/issues/2552

-   Add terminal password check via 'TTY_ROOT_PASSWORD' and describe it in
    default.conf, see https://github.com/rear/rear/pull/2539

-   Changes for NetBackup (NBU) support: Copy NetBackup PBX related files to
    the rescue system and start vxpbx_exchanged on boot. Add /usr/openv/tmp
    directory to the NBU skeleton. See https://github.com/rear/rear/pull/2544

-   RAWDISK: Add local rescue partition installation capability: Introduce a
    configuration variable 'RAWDISK_INSTALL_GPT_PARTITION_NAME', which is
    unset by default. When set, the rescue system will be installed to local
    disk partitions having the corresponding name. RAWDISK: fix local rescue
    partition installs (unmount before copying): While the recently created
    EFI boot partition is still mounted, its file system might not be fully
    synced. Unmounting ensures that the underlying loop block device is up to
    date before possibly being copied to local disk partitions. See
    https://github.com/rear/rear/pull/2538

-   BACKUP=BACULA: Make bacula aware of different location of config files see
    https://github.com/rear/rear/pull/2535

-   In layout/prepare/GNU/Linux/131_include_filesystem_code.sh fixed vfat mkfs
    using uuid from layout if possible see
    https://github.com/rear/rear/pull/2546

-   Completely overhauled USB filesystem kernel module handling: In
    prep/USB/default/380_copy_usb_fs_module.sh do no longer unconditionally
    add the USB filesystem to the MODULES and MODULES_LOAD arrays because
    there are systems where the USB filesystem (e.g. 'ext3') is no kernel
    module and then (via MODULES_LOAD and /etc/modules) "modprobe ext3" would
    fail in 40-start-udev-or-load-modules.sh with a false alarm "modprobe:
    FATAL: ... ext3 not found ..." message that would appear on the user's
    terminal during recovery system startup. See
    https://github.com/rear/rear/pull/2537

-   Add DP_LD_LIBRARY_PATH to include shared libraries used by BACKUP=DP see
    https://github.com/rear/rear/pull/2549

-   POWER architecture (ppc64) support for BACKUP=DP: Other platforms
    supporting the Data Protector Disk Agent, but not the Cell Console (GUI)
    that is only available on i386, x86_64 and ia64 are now supported with
    ReaR. This includes in particular ppc64. Checks unavailable on clients
    without the Data Protector Cell Console (GUI) are skipped. In such cases
    backup restore can be done using Data Protector GUI only.

-   BACKUP=NBKDC: Enhanced ReaR backup and restore to also work with NovaStor
    DataCenter 8.0 and higher plus fixed wording "NovaBACKUP DC" -> "NovaStor
    DC", see https://github.com/rear/rear/issues/2518

-   Provide final power to the user to skip the ISO_FILE_SIZE_LIMIT test: Skip
    the assert_ISO_FILE_SIZE_LIMIT function when there is no usable
    ISO_FILE_SIZE_LIMIT set so the user could specify ISO_FILE_SIZE_LIMIT=0 in
    his etc/rear/local.conf if he wants to skip the ISO_FILE_SIZE_LIMIT test.
    Aditionally enforce maximum 2GiB ISO_FILE_SIZE_LIMIT when the MODULES
    array contains 'loaded_modules' because MODULES+=( udf ) has no effect in
    this case unless it is loaded (which normally isn't).

-   Error out when files greater or equal ISO_FILE_SIZE_LIMIT should be
    included in the ISO: See the reasoning in default.conf why the default
    ISO_FILE_SIZE_LIMIT is 2GiB and why we error out when files >=
    ISO_FILE_SIZE_LIMIT should be included in the ISO. It is needed to aviod
    possibly disastrous failures later during "rear recover" that users who
    exceed that limit in exceptional cases get a hard (error) info to
    thoroughly test and verify whether or not things actually work for them.
    See https://github.com/rear/rear/pull/2525

-   Completely overhauled ldd test in 990_verify_rootfs.sh: Now if needed a
    special LD_LIBRARY_PATH is set only in the bash that runs ldd and that
    bash exits after ldd finished so the special LD_LIBRARY_PATH setting is
    gone with it. So there is no need to remember and restore some previously
    set LD_LIBRARY_PATH because nothing was changed in the bash that runs
    rear. Furthermore reporting when a binary requires additional libraries
    happens now in the same 'for' loop after the ldd test was run which
    further simplifies the code. See https://github.com/rear/rear/pull/2523

-   Skip the ldd test for ReaR files: In build/default/990_verify_rootfs.sh
    skip the ldd test for ReaR files (mainly bash scripts) where it does not
    make sense, cf.
    https://github.com/rear/rear/issues/2519#issuecomment-731196820

-   In 500_clone_keyboard_mappings.sh have more neutral wording in messages
    about possible keyboard issues and don't be needlessly verbose: It seems
    newer Debian-based systems (including Ubuntu) no longer contain any
    keymaps directory as part of the base system by default so including
    multi-keyboard support into the recovery system is impossible there. If
    the distro provides console-multi-keyboard support, ReaR includes it
    (without being verbose). If the distro has decided that this is not
    necessary, ReaR aligns with it (without being verbose). If the user has
    installed multi-keyboard support, ReaR aligns with it (without being
    verbose). Only when including the current keyboard mapping failed
    (i.e. when 'dumpkeys' failed) it shows subsequent messages on the user's
    terminal in any case. See https://github.com/rear/rear/issues/2519 and
    https://github.com/rear/rear/pull/2520

-   Restore LD_LIBRARY_PATH after reporting binaries with 'not found'
    libraries: In build/default/990_verify_rootfs.sh restore the
    LD_LIBRARY_PATH after reporting binaries with 'not found' shared object
    dependencies so that results are the same for the first 'ldd' run that
    finds binaries with 'not found' shared objects dependencies and the second
    'ldd' run that reports those 'not found' shared objects dependencies, see
    https://github.com/rear/rear/issues/2508#issuecomment-725914211

-   Improved TCG Opal 2 documentation doc/user-guide/13-tcg-opal-support.adoc
    cf. https://github.com/rear/rear/issues/2511 Better explained OS
    installation according to the suggestion in
    https://github.com/Drive-Trust-Alliance/sedutil/issues/301#issuecomment-723010843
    Additionally some information from an article on Ask Ubuntu are included
    https://askubuntu.com/a/1271171/1120528

-   Make recreating LUKS volumes work with optional cryptsetup options: The
    "cryptseup luksFormat" command does not require any of the type, cipher,
    key-size, hash, uuid option values because if omitted a cryptseup default
    value is used, cf.
    https://github.com/rear/rear/pull/2504#issuecomment-720341023 The right
    UUID values are mandatory for LUKS volumes that will be mounted during
    startup of the recreated system. But this does not mean ReaR should error
    out when there is no cryptsetup uuid value because it is possible to run
    "rear recover" with enforced MIGRATION_MODE and manually correct the
    restored /mnt/local/etc/crypttab file to use the new UUIDs before the
    initrd is recreated and the bootloader is (re)-installed
    cf. https://github.com/rear/rear/issues/2509

-   Allow setting a PBA-specific firmware configuration via the new
    OPAL_PBA_FIRMWARE_FILES configuration variable. Add '.../amdgpu/*' firmware
    files for AMD graphics hardware (if present) on TCG Opal pre-boot
    authentication (PBA) images, cf. https://github.com/rear/rear/issues/2474

-   Support OPAL 2 self-encrypting NVMe disk drives: Normally the OPAL device
    itself is used directly but NVMe devices have one or more namespaces per
    primary device and these namespaces act as disks,
    cf. https://github.com/rear/rear/issues/2475

-   Added initial LUKS2 support, see https://github.com/rear/rear/issues/2204
    Added new parameter 'type' to 'crypt' keyword used in disklayout.conf.
    Using this parameter allows to recreate the same version of LUKS as on the
    original system. Added LUKS version detection, parsing depending on
    version and usage of 'type' parameter.

-   New 036_valid_output_methods.sh to error out for unsupported OUTPUT
    methods: For "rear mkbackup/mkrescue/mkbackuponly/mkopalpba" (i.e. for all
    workflows that run the 'prep' stage) check that the OUTPUT method is
    actually implemented i.e. check that a usr/share/rear/output/$OUTPUT
    directory exists and error out when an OUTPUT method seems to be not
    supported to ensure that the user cannot specify a non-working OUTPUT in
    etc/rear/local.conf
    (cf. usr/share/rear/prep/default/035_valid_backup_methods.sh) see
    https://github.com/rear/rear/issues/2501

-   Redirect stdout and stderr to the log only in debug modes. In normal modes
    stdout and stderr are discarded (go now to /dev/null). The reason is to
    get rid of messages from command stdout and stderr that don't make sense
    for the user on their own unless there is more information in the log that
    provides context about the called command (e.g. what exact command was
    called in debugscript mode) see https://github.com/rear/rear/issues/2416
    and https://github.com/rear/rear/pull/2498

-   More verbose messages when components are excluded so that is is easier
    for the user to see directly on his terminal what the actual results are
    when he specified to exclude components in his etc/rear/local.conf and
    what components are automatically excluded by ReaR. The verbosity depends
    on if ReaR is run in verbose '-v' mode or even in debug '-d' or '-D' mode.

-   Inform the user about unsupported LUKS2 volumes but do not error out see
    https://github.com/rear/rear/issues/2491 plus some general code cleanup
    and improvements in layout/save/GNU/Linux/260_crypt_layout.sh

-   Update 05-integration.adoc: Explain that error messages in ReaR's log may
    not come from ReaR itself but from programs that are called by ReaR
    because stdout and stderr are redirected into ReaR's log file,
    cf. https://github.com/rear/rear/issues/2479

-   Have 'cd WORKING_DIR' in Source() function: Ensure that after each sourced
    file we are back in ReaR's usual working directory which is the current
    working directory when usr/sbin/rear is launched that is also the working
    directory of all the other scripts and config files that get sourced via
    the Source() function in lib/framework-functions.sh see
    https://github.com/rear/rear/issues/2461

-   In 400_copy_modules.sh skip copying kernel modules that are builtin
    modules. The new behaviour is that when modules are listed in
    modules.builtin and are also shown by modinfo then those modules are now
    skipped. Before for such modules the modules file(s) would have been
    included in the recovery system. See
    https://github.com/rear/rear/issues/2414

-   In backup/NETFS/default/500_make_backup.sh filter purely informational tar
    messages from output: Suppress purely informational tar messages from
    output like "tar: Removing leading / from member names" or "tar: Removing
    leading / from hard link targets" or "tar: /path/to/socket: socket
    ignored" but keep actual tar error or warning messages like "tar:
    /path/to/file: file changed as we read it" and show only messages that are
    prefixed with the name of the failed program (like 'tar:' or 'dd:') which
    works when tar or dd fail but falsely suppresses messages from openssl
    which needs to be fixed later,
    cf. https://github.com/rear/rear/pull/2466#discussion_r466347471

-   Fixed exit code logic in backup/NETFS/default/500_make_backup.sh: Commit
    https://github.com/rear/rear/commit/2674807f6ad48da80b193ae977d345ad2ef5fdd1
    removed the BACKUP_PROG_CRYPT_OPTIONS="cat" dummy code which broke the
    exit code logic because pipes_rc and backup_prog_shortnames did no longer
    match. Additionally ensure that the number of elements in both arrays are
    always the same.

-   Use ReaR specific TMP_DIR (not TMPDIR or hardcoded /tmp) plus some general
    cleanup work as noticed "by the way" in scripts, see
    https://github.com/rear/rear/issues/2460 and
    https://github.com/rear/rear/pull/2462

-   Adaptions and enhancements for BACKUP=CDM because the RBS agent file name
    changed in Rubrik CDM v5.1 from rubrik-agent-sunos5.10.sparc.tar.gz to
    rubrik-agent-solaris.sparc.tar.gz see
    https://github.com/rear/rear/issues/2441

-   Let 'dd' read and write up to 1M=1024*1024 bytes at a time to speed up
    things cf. https://github.com/rear/rear/issues/2369 and
    https://github.com/rear/rear/issues/2458

-   In default.conf change ISO_VOLID from "RELAXRECOVER" to "REAR-ISO" so the
    first ISO has the label "REAR-ISO" (8 characters) and subsequent ISOs get
    the labels "REAR-ISO_01" "REAR-ISO_02" ... respectively that have 11
    characters (the maximum length for FAT volume names) so things work now by
    default when the ISO image is used to (manually) create a FAT bootable USB
    stick, cf. https://github.com/rear/rear/issues/1565 and
    https://github.com/rear/rear/issues/2456

-   OPALPBA: Provide a permanent unlocking mode as a workaround because
    https://github.com/rear/rear/pull/2426 did not resolve the issue
    https://github.com/rear/rear/issues/2425 where for an HPE ML10Gen9 server
    it seems the firmware did not initialize properly during a 'simple' reboot
    so the only reliable way to boot was a power cycle after Opal disks were
    unlocked. To reboot with unlocked disks there is now a new unlocking mode
    "permanent" via OPAL_PBA_UNLOCK_MODE (see default.conf). Reactivating
    locking is then the responsibility of the user. Additionally enhanced
    security by disabling shell access via keyboard interrupt and switching to
    a password hash for OPAL_PBA_DEBUG_PASSWORD.

-   Use single quotes in the password settings examples because single quotes
    avoid issues with the special bash characters like $ in the password,
    cf. https://github.com/rear/rear/pull/2178

-   Update format-workflow.sh: For "rear format" show "Use 'rear format -
    -help' for more information" also when a "rear format" argument is not
    accepted to help the user what the right syntax is (e.g. "rear format
    help" and "rear format - help" do not work, only "rear format - -help"
    works) and provide a more helpful example "rear -v format - -efi /dev/sdX"
    that is actually neded for UEFI.

-   Support for systemd and parallel restore with Data Protector BACKUP=DP:
    Support starting Data Protector daemon 'omni.socket' via systemd in the
    recovery system. Restore performance has been increased by doing parallel
    restores now. Additional new script
    usr/share/rear/finalize/DP/default/500_restore_ssc.sh to restore the
    client certificate when Data Protector Secure Communication is used. Plus
    several general script cleanup things. See
    https://github.com/rear/rear/pull/2443

-   Supply default value for root in grub in UEFI ISO: Sometimes the search
    command in GRUB2 used in UEFI ISO does not find the root device. This was
    seen at least in Debian Buster running in Qemu (VirtualBox works fine,
    RHEL/CentOS in Qemu works fine as well). To make ReaR work in this case,
    set $root to a sensible value before trying search. The GRUB2 image
    created by grub-mkstandalone has $root set to memdisk, which can't work.
    This essentially matches how it used to work before
    https://github.com/rear/rear/pull/2293 and fixes
    https://github.com/rear/rear/issues/2434

-   Update 300_format_usb_disk.sh: In
    format/USB/default/300_format_usb_disk.sh when prompting user for size of
    EFI system partition on USB disk if no valid value is specified also use
    400 MiB as default (same as the default value in default.conf)
    cf. https://github.com/rear/rear/pull/1205#issuecomment-433336977 and
    https://github.com/rear/rear/commit/89e6a47c82fbfe8d059a4647755f94750fe28acc

-   Replaced $DATE usage with consistent variables START_SECONDS
    START_DATE_TIME_NUMBER and START_DATE_TIME_STRING see
    https://github.com/rear/rear/pull/2452

-   Various TCG Opal Improvements: OPALPBA, Ubuntu: Fix incomplete file
    exclusions: Fixes omissions reported in
    https://github.com/rear/rear/issues/2436 Uses COPY_AS_IS_EXCLUDE where
    possible. Removes files from the PBA system's staging directory where not
    copying could not be configured. OPALPBA: Improve boot splash on Ubuntu
    20.04: Takes into account a change from VT1 to VT7 to hide log messages
    during the boot process. Improves Plymouth boot splash usage to hide log
    messages during the reboot after unlocking disks. opaladmin: Add
    sub-commands 'deactivate', 'reactivate': Makes turning on and off hardware
    encryption easier on provisioned drives. TCG Opal-2: simplify quoting in
    messages and replace 'StopIfError' use
    cf. https://github.com/rear/rear/commit/daf35e235d0770c663ff8dba866dddec76586a27
    Explicitly issuing an unlock command before reactivating locking ensures
    that the device remains in an unlocked state when locking is reactivated.

-   Add an explanatory comment in lib/_input-output-functions.sh that using
    the ...IfError functions can result unexpected behaviour in certain cases
    cf. https://github.com/rear/rear/pull/2443#pullrequestreview-440609407 and
    https://github.com/rear/rear/issues/534 and
    https://github.com/rear/rear/issues/1415#issuecomment-315692391

-   Migrate XFS configuration files. When in MIGRATION_MODE, migrate/rename
    XFS configuration files so they follow disk mapping set by user. See
    https://github.com/rear/rear/issues/2333

## Supported and Unsupported Operating Systems

We try to keep our wiki page Test Matrix ReaR 2.7
https://github.com/rear/rear/wiki/Test-Matrix-ReaR-2.7
up-to-date with feedback we receive from the community.

ReaR 2.7 is supported on the following Linux based operating systems:

-   Fedora 29, 30, 31, 32, 33, and 34
-   RHEL 6, 7, 8, and 9
-   CentOS 6, 7, and 8
-   Scientific Linux 6 and 7
-   SLES 12 and 15
-   openSUSE Leap 15.x
-   Debian 8, and 9
-   Ubuntu 16, 17, 18 and 20

ReaR 2.7 dropped official support for the following Linux based operating
systems:

-   Fedora < 29
-   RHEL < 6
-   CentOS < 6
-   Scientific Linux < 6
-   SLES < 12
-   openSUSE Leap 42.x and before (i.e. openSUSE <= 13)
-   openSUSE Tumbleweed
-   Debian < 8
-   Ubuntu < 16

Usually ReaR 2.7 should also work on newer versions of the above listed
supported Linux based operating systems but sometimes arbitrary failures can
happen when software that is used by ReaR (like partitioning tools, filesystem
tools, bootloader tools, ISO image creating tools, networking tools, and so
on) changes in not fully backward compatible ways or when there are
innovations of the basic system (like kernel, storage, bootloader, init,
networking, and so on) that are not yet supported by ReaR.

In theory ReaR 2.7 should work on openSUSE Tumbleweed but in practice
arbitrary failures could happen at any time because the Tumbleweed
distribution is a pure rolling release version of openSUSE containing the
latest stable versions of all software
(cf. https://en.opensuse.org/Portal:Tumbleweed) so arbitrary changes of any
software are possible at any time that could arbitrarily break how ReaR works.

ReaR 2.7 may still work for SLES 11 and openSUSE Leap 42.x or even earlier
openSUSE versions but it is no longer sufficiently well tested there so
arbitrary regressions could appear. For example recreating LUKS encrypted volumes
does no longer work with SLES11 SP4 because cryptsetup 1.1.3 in SLES11 SP4 does
not support UUID and some other cryptsetup options that are used by default in ReaR 2.7.

ReaR 2.7 and earlier versions are known to no longer work reasonably well for
the following Linux based operating systems:

-   RHEL 5 (and probably also CentOS 5): See issue #1766
-   SLES 9 and 10: See issue #1842

If you require support for unsupported Linux operating systems you must
acquire a ReaR support contract.

Requests to port ReaR to another operating system (not Linux) can only be
achieved with serious sponsoring.

Supported and Unsupported Architectures

ReaR 2.7 is supported on:

-   Intel x86 type of processors
-   AMD x86 type of processors
-   PPC64 processors
-   PPC64LE processors

ReaR 2.7 may or may not work on:

-   Intel Itanium processors
-   ARM type of processors
-   IBM Z "s390x" type of processors

ReaR 2.7 does not support:

-   old PPC (32bit) processors

If you feel the need to get a fully functional ReaR working on one of the
above mentioned types of processors please buy consultancy from one of our
official developers.

## Supported ReaR versions

ReaR has a long history (since 2006) and we cannot support all released
versions. If you have a problem we urge you to install the latest stable ReaR
version or the development version (available on GitHub) before submitting an
issue.

We understand that it is not always possible to install on hundreds of systems
the latest version so we are willing to support previous versions of ReaR when
you buy a support contract. We cannot handle the big amount of support
requests anymore on a voluntary base and we must give paid projects priority,
therefore, we urge our customers to buy a support contract for one or more
systems. You buy time with our core developers.

