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

Before making the first backup with RBME we have to create an exclude list:

    # cat /etc/backup-excludes.lst 
    /var/tmp
    /tmp
    /proc
    /run
    /sys

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

### References

* [GitHub rbme project](https://github.com/schlomo/rbme)
