# Configuring BACKUP=NETFS example

This configuration will create a bootable ISO image and store the backup on an NFS server.

## Configuration Example

Create or edit the local.conf file:

```bash
# /etc/rear/local.conf
OUTPUT=ISO
BACKUP=NETFS
BACKUP_OPTIONS="nfsvers=3,nolock"
BACKUP_URL=nfs://<NFS_SERVER_IP>/path/to/backup
```

Explanation:

 - `OUTPUT=ISO`: Specifies that the output should be a bootable ISO image.
 - `BACKUP=NETFS`: Uses the NETFS method for backup, which supports network file systems like NFS.
 - `BACKUP_OPTIONS="nfsvers=3,nolock"`: Sets the NFS mount options. Here, it specifies NFS version 3 and disables file locking.
 - `BACKUP_URL=nfs://<NFS_SERVER_IP>/path/to/backup`: The URL of the NFS server where the backup will be stored. Replace <NFS_SERVER_IP> with the actual IP address of your NFS server and /path/to/backup with the actual path on the NFS server.

## Running the Backup

To create the backup, run the following command:

```bash
rear -v mkbackup
```

This command will create the backup and store it on the specified NFS share.
