## swap space
```sh
sudo fallocate -l 2G /swapfile  # Allocate 2GB swap file
sudo chmod 600 /swapfile        # Set the correct permissions
sudo mkswap /swapfile           # Make the swap file usable
sudo swapon /swapfile           # Enable swap

If fallocate does not work, you can use the dd method:
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

Make the swap permanent (so it persists across reboots):
Add the swap file entry to /etc/fstab:

sudo nano /etc/fstab
```
## fstab
The line `/swapfile none swap sw 0 0` added to the `/etc/fstab` file is used to configure **swap space** on your system. Here's what each part means:

### Breakdown of the Entry:

1. **`/swapfile`**: 
   - This specifies the **location of the swap file**. In this case, it's the file you created for swap space, typically located at `/swapfile`.

2. **`none`**: 
   - This indicates that there is **no mount point** for the swap file. Unlike regular file systems that need a directory to mount to (e.g., `/home`), swap doesn't need a mount point, hence `none`.

3. **`swap`**:
   - This specifies the **file system type**. Since this is a swap space, the file system type is set to `swap` to let the system know that it's not a normal file system, but rather one used for virtual memory.

4. **`sw`**:
   - This is a set of **mount options**. The `sw` option enables the swap space. In this case, it tells the system to **use the swap space** for virtual memory.

5. **`0`**:
   - This is the **dump** option, which is used by the `dump` command (a backup utility). For swap files, this is typically set to `0`, meaning the swap file is not included in backups.

6. **`0`**:
   - This is the **fsck** (file system check) option. For swap files, this is also set to `0`, meaning the system does not check the swap file for consistency during boot.

### Full Meaning:
- `/swapfile`: Specifies the path to the swap file.
- `none`: No mount point is needed for swap space.
- `swap`: Specifies that it's swap space (not a regular file system).
- `sw`: Enables the swap space.
- `0 0`: No backup or file system check is needed for swap files.

By adding this line to `/etc/fstab`, the swap file will be automatically enabled every time your system boots, ensuring that swap space is available without needing manual intervention after each reboot.
