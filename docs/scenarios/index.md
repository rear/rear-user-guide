# Scenarios Overview

In this chapter will be go over some simple and more complex examples used with ReaR.

## Use NAS share to archive rear image and OS with zstandard as compression algorithm

Also, we use as temporary file system to create the ISO image not /tmp, but /oem - see `export TMPDIR=/oem`

Furthermore, all file systems and volume groups will be part of the OS archive and therefore, also for the recovery process. We commented out the variable setting `# ONLY_INCLUDE_VG=( "vg00" )` and explicit defined variable `AUTOEXCLUDE_DISKS=no` to achieve this.

To force the zstandard as compression algorithm instead of the default gzip we added the `zstd` executable to the `COPY_AS_IS` variable array and defined the variables `BACKUP_PROG_COMPRESS_OPTIONS` and `BACKUP_PROG_COMPRESS_SUFFIX`.

```bash
export TMPDIR=/oem
# ONLY_INCLUDE_VG=( "vg00" )
BACKUP=NETFS
NETFS_PREFIX=image
NETFS_KEEP_OLD_BACKUP_COPY=yes
CLONE_USERS=( "${CLONE_USERS[@]}" oracle )
CLONE_GROUPS=( "${CLONE_GROUPS[@]}" dba )
TIMESYNC=CHRONY
TIMESYNC_SOURCE=10.255.255.10
SSH_ROOT_PASSWORD="rear"
COPY_AS_IS=( "${COPY_AS_IS[@]}" /etc/oratab clear $(which zstd) )
POST_RECOVERY_SCRIPT=/mnt/local/u02/restore_oracle_u02_database_directory.sh
AUTOEXCLUDE_DISKS=no
BACKUP_PROG_EXCLUDE=( ${BACKUP_PROG_EXCLUDE[@]} '/u02/ora*' '/u02/recoveryarea01' '/u01/app/oracle/admin/JHHD0173/diag/rdbms/*' '/u01/app/oracle/admin/JHHD0173/RMAN/logs/*' '/app/scm-dvl/SCM-Releases/*' )
BACKUP_OPTIONS="nfsvers=4,nolock"
BACKUP_URL=nfs://mynas.example.com/rear_backups/linux_images/my-server.example.com;
PRE_BACKUP_SCRIPT=( 'rm -rf /tmp/cfg2html*' )
USE_CFG2HTML=no
FIRMWARE_FILES=( 'no' )
BACKUP_PROG_COMPRESS_OPTIONS=( '--use-compress-program=zstd' )
BACKUP_PROG_COMPRESS_SUFFIX=".zst"
```
