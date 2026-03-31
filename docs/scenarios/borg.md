# External backup using BACKUP=BORG method

[BorgBackup](https://www.borgbackup.org/) (short: Borg) is a deduplicating backup program. Optionally, it supports compression and authenticated encryption.

Borg is designed for efficient and secure backups. Its main goal is to provide an efficient and secure way to backup data. The data deduplication technique used makes Borg suitable for daily backups since only changes are stored, which results in a minimal disk space usage. The built-in encryption allows you to backup data to targets that are not fully trusted.

ReaR has native support for BorgBackup via `BACKUP=BORG`.

## Installing BorgBackup

On Debian/Ubuntu systems, BorgBackup can be installed with:

    # apt install borgbackup

On RedHat-based systems, BorgBackup is available in the EPEL repository:

    # dnf install borgbackup

For other installation methods (standalone binary, pip, etc.), see the [BorgBackup installation documentation](https://borgbackup.readthedocs.io/en/stable/installation.html).

If BorgBackup is installed in a non-standard location (e.g. `/usr/local/bin/borg`), specify the path using:

    PROGS_BORG=( /usr/local/bin/borg )

## Setting up a BorgBackup repository

Before using ReaR with Borg, you need to initialize a Borg repository on the backup server. The following example initializes an encrypted repository using the `repokey` encryption mode:

    # borg init --encryption=repokey user@backupserver:/datapool/backups/borgbackup/systems/myhostname

With `repokey`, the repository key is stored in the remote repository itself. Make sure to export and save the key in a safe location:

    # borg key export user@backupserver:/datapool/backups/borgbackup/systems/myhostname /root/.borg-keys/myhostname.key

With `keyfile` encryption, the key is stored locally (e.g. in `/root/.borg-keys/`). Set `BORG_KEYS_DIR` to tell Borg where to find the key.

### Passphrase file

Store the repository passphrase in a file readable only by root:

    # echo 'your-secure-passphrase' > /root/.borg-passphrase
    # chmod 400 /root/.borg-passphrase

### SSH key for the backup user

ReaR connects to the Borg server over SSH. Create a dedicated SSH key pair for the backup user and configure passwordless access on the backup server:

    # ssh-keygen -t ed25519 -f /root/.ssh/id_sa-borg -N ''

Add the public key (`/root/.ssh/id_sa-borg.pub`) to the `~/.ssh/authorized_keys` of the backup user on the backup server, and verify that the connection works:

    # ssh -i /root/.ssh/id_sa-borg sa-borg@backupserver 'borg list /datapool/backups/borgbackup/systems/myhostname'

### Exclude file

To avoid backing up unnecessary directories, create a Borg exclude file:

    # cat /root/.borg-exclude
    /proc
    /sys
    /dev
    /run
    /tmp
    /var/tmp
    /mnt
    /media

## Configuring ReaR

Create or edit `/etc/rear/local.conf` with the following content. This example uses SFTP to transfer the rescue ISO to the backup server with the same credentials used for Borg:

    # This file etc/rear/local.conf is intended for the user's
    # manual configuration of Relax-and-Recover (ReaR).
    # BorgBackup
    BACKUP=BORG
    PROGS_BORG=( /usr/local/bin/borg )
    # borg needs some extra LIBS not automatically found:
    LIBS+=( /usr/lib/x86_64-linux-gnu/lib*.so* /lib64/lib*.so* )
    BORGBACKUP_USERNAME="sa-borg"
    BORGBACKUP_HOST="192.168.1.1"
    BORGBACKUP_REPO="/datapool/backups/borgbackup/systems/${HOSTNAME}"
    BORGBACKUP_PORT=22
    BORGBACKUP_TIMESTAMP="$(date +%Y-%m-%dT%H:%M:%S)"
    BORGBACKUP_PASSPHRASE_FILE=/root/.borg-passphrase

    # When we use borg outside ReaR we might have a borg exclude file which we should include in ReaR
    BORGBACKUP_EXCLUDE_FILE='/root/.borg-exclude'
    BORGBACKUP_COMPRESSION="lz4"

    # If BORGBACKUP_ENC_TYPE="keyfile" then we need BORG_KEYS_DIR=/root/.borg-keys
    # repokey will store its key in the remote borg repo (do not forget to export the key for safety)
    BORGBACKUP_ENC_TYPE="repokey"

    BORGBACKUP_ARCHIVE_PREFIX="$HOSTNAME"
    BORGBACKUP_CREATE_SHOW_STATS=true
    BORGBACKUP_CREATE_SHOW_PROGRESS=true
    BORGBACKUP_IGNORE_WARNING=true
    BORGBACKUP_PRUNE_KEEP_LAST=
    BORGBACKUP_PRUNE_KEEP_MINUTELY=
    BORGBACKUP_PRUNE_KEEP_HOURLY=5
    BORGBACKUP_PRUNE_KEEP_DAILY=7
    BORGBACKUP_PRUNE_KEEP_WEEKLY=4
    BORGBACKUP_PRUNE_KEEP_MONTHLY=6
    BORGBACKUP_PRUNE_KEEP_YEARLY=1
    BORGBACKUP_PRUNE_SHOW_RC="no"
    BORGBACKUP_PRUNE_SHOW_LIST="no"
    # export BORG_KEYS_DIR=/root/.borg-keys

    COPY_AS_IS_BORG+=( $BORGBACKUP_PASSPHRASE_FILE $BORGBACKUP_EXCLUDE_FILE $BORG_KEYS_DIR /root/.config/borg borg locale /usr/bin/crypto )

    [[ -f "$BORGBACKUP_PASSPHRASE_FILE" ]] && \
       { export BORG_PASSPHRASE="$( cat $BORGBACKUP_PASSPHRASE_FILE | crypto aes-dec )" ; } 2>/dev/$SECRET_OUTPUT_DEV

    # Tell borg to use a special SSH key with ssh:
    export BORG_RSH='ssh -i /root/.ssh/id_sa-borg'

    # Where is borg located on the backupserver:
    export BORG_REMOTE_PATH='/usr/local/bin/borg'

    # For "Warning: The repository at location ... was previously located at ...":
    export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

    # The ReaR rescue image type and location to store
    OUTPUT=ISO

    # We need to add a dummy password to avoid lftp asks for a password even when we are using
    # sftp with SSH keys (see issue https://github.com/rear/rear/issues/2824)
    OUTPUT_URL="sftp://${BORGBACKUP_USERNAME}:dummypassword@${BORGBACKUP_HOST}${BORGBACKUP_REPO}"

    # When you connect to sa-borg (non-root) user from root, then ~/.lftprc should contain:
    # set sftp:connect-program "ssh -a -x -i /root/.ssh/id_sa-borg"
    COPY_AS_IS+=( /root/.lftprc )

    # We need to root SSH keys to access the remote server via password-less ssh
    COPY_AS_IS+=( '/root/.ssh' )
    SSH_FILES="yes"
    SSH_UNPROTECTED_PRIVATE_KEYS=true

    # Use the same IP address(es) of the this system to be activated in the rescue OS
    USE_STATIC_NETWORKING="y"

    # To be able to login via ssh
    { SSH_ROOT_PASSWORD="relax" ; } 2>/dev/$SECRET_OUTPUT_DEV

    # To save space limit what we need within rescue image (no firmware and only the loaded kernel modules)
    FIRMWARE_FILES=( )
    MODULES=( 'loaded_modules' )

    PROGRESS_MODE="plain"
    PROGRESS_WAIT_SECONDS="10"

    BACKUP_PROG_EXCLUDE+=( '/apps/*' '/datapool/*' )

### Key configuration variables

| Variable | Description |
|---|---|
| `BORGBACKUP_USERNAME` | Username on the Borg backup server |
| `BORGBACKUP_HOST` | Hostname or IP address of the Borg backup server |
| `BORGBACKUP_REPO` | Path to the Borg repository on the backup server |
| `BORGBACKUP_PORT` | SSH port to use when connecting to the backup server (default: 22) |
| `BORGBACKUP_PASSPHRASE_FILE` | Path to a file containing the repository passphrase |
| `BORGBACKUP_EXCLUDE_FILE` | Path to a file listing paths to exclude from the Borg backup |
| `BORGBACKUP_COMPRESSION` | Compression algorithm to use (e.g. `lz4`, `zstd`, `none`) |
| `BORGBACKUP_ENC_TYPE` | Encryption mode: `repokey`, `keyfile`, or `none` |
| `BORGBACKUP_ARCHIVE_PREFIX` | Prefix for Borg archive names (defaults to hostname) |
| `BORGBACKUP_TIMESTAMP` | Timestamp appended to the archive name |
| `BORGBACKUP_CREATE_SHOW_STATS` | Show backup statistics after creation (`true`/`false`) |
| `BORGBACKUP_CREATE_SHOW_PROGRESS` | Show progress during backup creation (`true`/`false`) |
| `BORGBACKUP_IGNORE_WARNING` | Suppress non-fatal Borg warnings (`true`/`false`) |
| `BORGBACKUP_PRUNE_KEEP_HOURLY` | Number of hourly archives to keep during pruning |
| `BORGBACKUP_PRUNE_KEEP_DAILY` | Number of daily archives to keep during pruning |
| `BORGBACKUP_PRUNE_KEEP_WEEKLY` | Number of weekly archives to keep during pruning |
| `BORGBACKUP_PRUNE_KEEP_MONTHLY` | Number of monthly archives to keep during pruning |
| `BORGBACKUP_PRUNE_KEEP_YEARLY` | Number of yearly archives to keep during pruning |
| `BORGBACKUP_PRUNE_SHOW_RC` | Show return code of prune operation (`"yes"`/`"no"`) |
| `BORGBACKUP_PRUNE_SHOW_LIST` | Show list of pruned archives (`"yes"`/`"no"`) |
| `COPY_AS_IS_BORG` | Extra files/directories to copy into the rescue image for Borg |
| `BORG_RSH` | SSH command used by Borg (useful for specifying a custom SSH key) |
| `BORG_REMOTE_PATH` | Path to the `borg` binary on the backup server |
| `BORG_RELOCATED_REPO_ACCESS_IS_OK` | Suppress warnings when a repository has been moved |

### Notes on OUTPUT_URL and lftp

When using SFTP to transfer the rescue ISO, ReaR uses `lftp` under the hood. Even when using SSH keys for authentication, `lftp` may prompt for a password. To work around this (see [issue #2824](https://github.com/rear/rear/issues/2824)), add a dummy password to the `OUTPUT_URL`:

    OUTPUT_URL="sftp://${BORGBACKUP_USERNAME}:dummypassword@${BORGBACKUP_HOST}${BORGBACKUP_REPO}"

Additionally, configure lftp to use the correct SSH key by creating `/root/.lftprc`:

    set sftp:connect-program "ssh -a -x -i /root/.ssh/id_sa-borg"

And include the file in the rescue image:

    COPY_AS_IS+=( /root/.lftprc )

## Running ReaR mkbackup

To create the rescue image and run the Borg backup:

    # rear -v mkbackup

## Recovering using ReaR and BorgBackup

Boot the system from the ReaR rescue ISO. Once in the rescue environment, run:

    # rear -v recover

ReaR will restore the disk layout and then use Borg to restore the files from the latest archive in the repository.

### References

* [BorgBackup home page](https://www.borgbackup.org/)

* [BorgBackup documentation](https://borgbackup.readthedocs.io/en/stable/)

* [BorgBackup GitHub repository](https://github.com/borgbackup/borg)

* [ReaR issue #2824 - lftp dummy password workaround](https://github.com/rear/rear/issues/2824)
