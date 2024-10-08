# Getting started with ReaR

Relax-and-Recover (ReaR) is a disaster recovery tool designed for GNU/Linux. Given the vast number of GNU/Linux variants, we strive to support the majority of them. However, please understand that it is not possible to accommodate every variant.

## Software requirements
Relax-and-Recover aims to have as little dependencies as possible, however over time certain capabilities were added using utilities and specific
features, causing older distributions to fall out of support. We try to avoid this where practically possible and be conservative to add new dependencies.

The most basic requirement for Relax-and-Recover is having `bash`, and ubiquitous Linux tools like:

 - dd (coreutils)
 - ethtool
 - file
 - grep
 - gzip
 - ip (iproute[2])
 - mount (util-linux-ng)
 - ps (procps)
 - sed
 - ssh (openssh-clients)
 - strings (binutils)
 - tar
 - ...

Optionally, some use-cases require other tools:

 - lsscsi and sg3_utils (for OBDR tape support)
 - mkisofs or genisoimage (for ISO output support)
 - syslinux (for ISO or USB output support)
 - syslinux-extlinux (for USB support)
 - ebiso (for SLES UEFI booting)

In some cases having newer versions of tools may provide better support:

 - syslinux >= 4.00 (provides menu support)
 - parted

In case we are using **BACKUP=NETFS** with nfs or cifs we might need also:

 - nfs-client
 - cifs-utils

## Distribution support
As a project our aim is not to exclude any distribution from being supported,
however (as already noted) some older distributions fell out of support over
time and there is little interest from the project or the community to spend
the effort to add this support.

On the other hand there is a larger demand for a tool like Relax-and-Recover
from the Enterprise Linux distributions, and as a result more people are
testing and contributing to support those distributions.

Currently we aim to support the following distributions by testing them
regularly:

 - Red Hat Enterprise Linux and derivatives: RHEL7, RHEL8 and RHEL9
 - SUSE Linux Enterprise Server 12 and 15
 - Ubuntu LTS: 18, 20, 22, 24

Distributions dropped as supported:

 - Ubuntu LTS <18
 - Fedora <30
 - RHEL 3, 4, 5, and 6
 - SLES <12
 - openSUSE <11
 - Debian <8

Distributions known to be 'unsupported' are:

 - Ubuntu LTS 8.04 (as it does not implement `grep -P`)


## Known limitations
Relax-and-Recover offers a lot of flexibility in various use-cases, however it
does have some limitations under certain circumstances:

 - Relax-and-Recover depends on the software of the running system. When
   recovering this system to newer hardware, it is possible that the hardware
   support of the original system does not support the newer hardware.

 - Relax-and-Recover supports recovering to different hardware, but it cannot
   always automatically adapt to this new environment. In such cases it
   requires a manual intervention to e.g.

     * modify the _disklayout.conf_ to indicate the number of controller, disks
     or specific custom desires during restore

     * reduce the partition-sizes/LV-sizes when restoring to smaller storage

     * pull network-media or configure the network interfaces manually

 - Depending on your back-up strategy you may have to perform actions, like:

     * insert the required tape(s)

     * perform commands to restore the backup


## Installation

You can find the RPM and DEB packages from our web site at [https://relax-and-recover.org/download/](https://relax-and-recover.org/download/)

The latest stable versions of Fedora and SLES can be installed via `yum` (on RHEL 6 and 7), or via `dnf` (on RHEL 8) or `zypper` (on SLES).
However, keep in mind, when you download ReaR from the vendors repositories that the version of ReaR is not always the latest version and will vary from the upstream version.
Furthermore, if you have problems with the vendors version of ReaR please contact the vendor directly via their support channels. If required the vendor will contact us via the upstream channels (through our GitHub issues).

On our download pages you will find two sections (stable and snapshot versions) of ReaR packages. Select the stable section if you want to play it safe, or the snapshot section if you have issues with a stable version as the snapshot versions are nightly rebuild and may or may not contain your fixes. Please check the current [issues submitted at GitHub](https://github.com/rear/rear/issues) to check if your problem has already been reported.

### From downloaded RPM packages
Simply install (or update) the provided packages using
the command: `rpm -Uhv rear-2.6-1.el8.x86_64.rpm`

You can test your installation by running `rear dump`:

```bash
[root@system ~]# rear dump
System definition:
                                    ARCH = Linux-x86_64
                                      OS = GNU/Linux
                               OS_VENDOR = RedHatEnterpriseServer
                              OS_VERSION = 8.2
```

### From DEB packages

On a Debian system (or Ubuntu) you can download the DEB packages from our download page and install it with the command:

```bash
dpkg -i rear*.deb
```

On Debian (Ubuntu) use the following command to install missing dependencies:

```bash
apt-get -f install
```

### From source

The latest and greatest sources are available at GitHub location : [https://github.com/rear/rear](https://github.com/rear/rear)

To make local copy with our github repository just type:

```
git clone git@github.com:rear/rear.git
```

## File locations

Remember the general configuration file is found at `/usr/share/rear/conf/default.conf`. In that file you find all variables used by `rear` which can be overruled by redefining these in the `/etc/rear/site.conf` or `/etc/rear/local.conf` files. Please do not modify the `default.conf` file itself, but use the `site.conf` or `local.conf` for this purpose.

!!! note
    Important note about the configuration files inside ReaR. Treat these as Bash scripts! ReaR will source these configuration files, and therefore, if you make any syntax error against Bash scripting rules ReaR will break.

!!! note "Test your configuration changes"
    If you modify the `/etc/rear/local.conf` or any other configuration file you can simply test for syntax errors by executing the following command: **bash -n /etc/rear/local.conf**
