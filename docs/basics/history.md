# A bit of history

Relax-and-Recover (ReaR) was not the first project in its kind. Around the year 2000 there were two major Open Source Linux Disaster Recovery projects available:

- [Make CD-ROM Recovery (mkcdrec)](https://mkcdrec.sourceforge.net/) - The direct predecessor of ReaR, created by Gratien D'haese. See the [mkCDrec section](#make-cd-rom-recovery-mkcdrec) below for its full history.
- [Mondo Rescue](http://www.mondorescue.org/) - First released around 1999 (needs verification) by Hugo Rabson, the original author. Later, Bruno Cornec took over as the lead and continues in that role to this day.

## Make CD-ROM Recovery (mkCDrec)

[mkCDrec](https://mkcdrec.sourceforge.net/) was a pioneering Open Source Linux disaster recovery tool, written entirely in Bash and hosted on SourceForge. Its primary purpose was to create a bootable CD-ROM (or other boot media) directly from a running Linux system, which could then be used to fully restore that system to bare metal after a failure.

### Key features and capabilities

- **Bootable recovery media** — generated a self-contained bootable ISO image containing the rescue environment and system configuration.
- **Hardware auto-detection** — automatically detected and configured hardware (storage controllers, network adapters, etc.) during the recovery process.
- **Filesystem support** — supported the major Linux filesystems of the era, including ext2, ext3, ReiserFS, and JFS.
- **Network-based recovery** — supported restoring backups over the network (NFS, FTP) in addition to local tape and CD/DVD media.
- **ISO media check** — included a mediacheck feature to verify the integrity of the generated ISO image, providing a timestamp of when it was created.
- **isolinux integration** — used isolinux as the boot loader for the generated CD, including support for custom splash screens.
- **NTFS volume handling** — early support for backing up NTFS volumes by zeroing unused space and using `dd` with compression.

### Timeline

| Year | Event |
|------|-------|
| 2000 | mkCDrec first released in November by Gratien D'haese |
| 2006 | Gratien D'haese and Schlomo Shapiro perform a complete rewrite of mkCDrec, resulting in the birth of Relax-and-Recover (ReaR) |
| 2012 | Gratien officially stops development on mkCDrec to focus entirely on ReaR |

!!! note
    For systems running Linux kernel versions older than 2.6, ReaR cannot be used. mkCDrec remains a viable alternative for those legacy systems.

## Relax-and-Recover (ReaR) milestones

ReaR 1.7.25, released in mid-2010, marked a significant breakthrough for the project as the number of downloads skyrocketed after SuSe included it in its HA portfolio. A few years later, in mid-2015, ReaR 1.17.2 was incorporated into the core of the RedHat RHEL portfolio. Since then, we have lost track of how many people use ReaR daily or weekly, as both SLES and RHEL maintain their own branches of ReaR in their distributions.


When I remember other funny things I will add it to this history page.

