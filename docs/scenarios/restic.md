# External backup using restic

[Restic](https://restic.net/) is a modern backup program that can back up your files from Linux, BSD, MacOS, or Windows. Restic is easy, being a single executable that you can run without a complex setup. Restic performs incremental backups, only transferring the parts that actually changed in the files you back up.

Currently there is no workflow in ReaR that supports restic. You can [sponsor](https://relax-and-recover.org/support/sponsors) us to create a `BACKUP=RESTIC` workflow inside ReaR.

However, do not despare as the EXTERNAL workflow can be used to make backups and restores through ReaR. It is not official supported by the ReaR maintainers, but it can be done. Be aware that you cannot complain to us if it doesn't work as what we describe below is not a real integration in ReaR, but rather a last tool to perform the backup and/or recover yourself with your own favorite backup tool.

## Install the restic software

On RedHat alike OSes you first of all need to install epel-release:

    # dnf install epel-release

Once the epel repository is available is available install the restic application with the command:

    # dnf install restic

For other ways to install restic see the [installation](https://restic.readthedocs.io/en/latest/020_installation.html) page of the docmentation.

## Prepare a backup repository

The instructions are nicely explained in [preparing a new repo](https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html) section of the documentation.
Also, the method you want to use to reach your repo on the backup server must be carefully selected.

We use the *sftp* method, therefore, the secure shell access to the backup server has to work without entering passwords.

Before we can make backups we need to initialize a restic backup repository with the `init` option and thereby provide a really good password:

    # restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup init
    enter password for new repository: restic

Of course, as we are just testing out restic our password really sucks - do NOT use a simple password for production!

To avoid that we need to enter the password each time we run `restic` we chose to save the password in a special file:

    # cat /etc/restic-password
    restic

And, we changed to permissions of the file `/etc/restic-password` to mode 0400.

## Excluding files/directories from the backup scheme

 In order to avoid too much data being backed up, or even avoiding hangs or never ending backups create an exclude file for `restic`:

    # cat /etc/restic_exclude_files 
    /proc
    /sys
    /media
    /mnt
    /run
    /tmp
    /var/tmp

## Configring ReaR

Of course we assume that the `rear` package was already installed, if not, do this first.

You can create a `/etc/rear/local.conf` or `/etc/rear/restic.conf file which contains:

    [root@alma rear]# cat restic.conf 
    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    
    BACKUP=EXTERNAL
    OUTPUT=ISO
    OUTPUT_URL=nfs://192.168.122.1/apps/export/RBME
    
    COPY_AS_IS+=( '/etc/restic_exclude_files' '/etc/restic-password' '/root/.ssh/' )
    SSH_FILES="yes"
    SSH_UNPROTECTED_PRIVATE_KEYS=true
    
    REQUIRED_PROGS+=( 'restic' )
    EXTERNAL_BACKUP="restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup backup / /boot --one-file-system --exclude-file /etc/restic_exclude_files --password-file /etc/restic-password"
    EXTERNAL_RESTORE="restic -r sftp:root@192.168.122.1:/apps/export/RBME/restic-backup restore latest --target /mnt/local --password-file /etc/restic-password"
    
    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"
    
    # To be able to login via ssh
    SSH_ROOT_PASSWORD="relax"
    
    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( 'no' )
    MODULES=( 'loaded_modules' )
    
    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"


### References

* [Restic - Backups done right](https://restic.net/)

* [Restic GitHub home page](https://github.com/restic/restic)

* [Restic Documentation](https://restic.readthedocs.io/en/latest/)
