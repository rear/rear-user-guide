# Introduction

Relax-and-Recover (ReaR) is the leading Open Source bare metal disaster recovery
solution. It is a modular framework with many ready-to-go workflows for
common situations.

!!! note
    Relax-and-Recover (ReaR) software package has been added to the core of Red Hat's Enterprise Linux and
    SuSe did the same for their SLES Operating Systems. Furthermore, Debian and Ubuntu also provide packages of ReaR to download from their repositories. However, be aware if you are using one of these vendors ReaR package it might not be the latest packages the upstream provides on their [download page](http://relax-and-recover.org/download/). On the other hand, if you want to have support from your vendor directly then only use the ReaR package they provide. If there is a serious bug then the vendors will open an [issue](https://github.com/rear/rear/issues) with the upstream project.

Relax-and-Recover produces a bootable image which can recreate the system's
original storage layout. Once that is done it initiates a restore from backup.
Since the storage layout can be modified prior to recovery, and disimilar
hardware and virtualization is supported, Relax-and-Recover offers the
flexibility to be used for complex system migrations.

Currently Relax-and-Recover supports various boot media (incl. ISO, PXE,
OBDR tape, USB or eSATA storage), a variety of network protocols (incl.
sftp, ftp, http, nfs, cifs) as well as a multitude of backup strategies
(incl.  IBM TSM, Micro Focus Data Protector, Symantec NetBackup, EMC NetWorker [Legato],
SEP Sesam, Galaxy [Simpana], Bacula, Bareos, RBME, rsync, duplicity, Borg).

Relax-and-Recover was designed to be easy to set up, requires no maintenance
and is there to assist when disaster strikes. Its setup-and-forget nature
removes any excuse for not having a disaster recovery solution implemented.

Recovering from disaster is made very straight-forward by a 2-step recovery
process so that it can be executed by operational teams when required.
When used interactively (e.g. when used for migrating systems), menus help
make decisions to restore to a new (hardware) environment.

Extending and integrating Relax-and-Recover into complex environments is made
possible by its modular framework. Consistent logging and optionally extended
output help understand the concepts behind Relax-and-Recover, troubleshoot
during initial configuration and help debug during integration.

If you have time to watch an introduction presentation about Relax-and-Recover then we can recommend the following presentation given by Gratien D'haese during the OpenSuSe Conference (of 2015).

<iframe width="280" height="210" src="https://www.youtube.com/embed/lBM7_Lxaorw"  frameborder="0" allowfullscreen><p>OSEM 2015, Relax-and-Recover simplifies Linux Disaster Recovery</p></iframe>


[Professional services and support](http://relax-and-recover.org/support/) are available.


## Relax-and-Recover project
The support and development of the Relax-and-Recover project takes place
on Github:

[Relax-and-Recover website](http://relax-and-recover.org/)

[Github project](http://github.com/rear/rear/)

In case you have questions, ideas or feedback about this document, you
can contact the development team by creating  an item on the Relax-and-Recover User Guide issues pages at:
https://github.com/rear/rear-user-guide/issues

!!! note
       You may always prepare a pull request with your updates, being a new chapter, typos and so on.


## Design concepts
Based on experience from previous projects, a set of design principles were
defined, and improved over time:

 - Focus on easy and automated disaster recovery
 - Modular design, focused on system administrators
 - For Linux (and possibly Unix operating systems)
 - Few external dependencies (Bash and standard Unix tools)
 - Easy to use and easy to extend
 - Easy to integrate with *real* backup software (Open Source and commercial solutions)

The goal is to make Relax-and-Recover as user-friendly as possible. It will require
only the applications necessary to fulfill the tasks for which it is configured and designed.

Furthermore, Relax-and-Recover should be platform-independent and ideally install as a set 
of scripts that utilize the resources provided by the Linux operating system.


## Features and functionality
Relax-and-Recover has a wide range of features:


 - HP SmartArray and CCISS driver integration
 - Software RAID integration
 - Disk layout change detection for monitoring
 - One-Button-Disaster-Recovery (OBDR) tape support
 - DRBD filesystem support
 - Bacula or Bareos tape support
 - Multiple DR images per system on single USB storage device
 - USB ext3/ext4 support
 - GRUB[2] bootloader re-implementation
 - UEFI support
 - ebiso support (needed by SLES UEFI ISO booting)
 - Add Relax-and-Recover entry to local GRUB configuration (optional)
 - Nagios and webmin integration
 - Syslinux boot menu
 - Storing rescue/backup logfile on rescue media
 - Restoring to different hardware (of the same hardware architecture)
 - Red Hat Enterprise Linux support (included derivated Operating Systems)
 - SuSe SLES support
 - Debian and Ubuntu support
 - Various usability improvements
 - Serial console support auto-detected
 - Lockless workflows
 - USB udev integration to trigger mkrescue on inserting USB device
 - Migrate UUID from disks and MAC addressed from network interfaces
 - Integrates with Disaster Recovery Linux Manager (DRLM)
 - Data deduplication with Borg as backend
 - Block device level backup/restore
 - Multipath support for SAN devives
 - See the full list of new features on our [Release Notes](../releasenotes)

