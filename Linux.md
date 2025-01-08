### /etc/passwd vs /etc/shadow
The major difference is that they contain different pieces of data.
- passwd contains the users' public information (UID, full name, home directory) => readable by everyone,
```sh 
google:x:1000:1000:google search:/home/google:/bin/bash
```
- while shadow contains the hashed password and the password expiry data. => readable by root
```sh
amazon:$6$GjtgpLxdaueFJfiCRlZpg3qYTGjp.:18868:0:99999:7:::
```
> Note: The /etc/passwd and /etc/shadow files are linked/connected together by the user ID (UID) field.

# MOUNT FILE System 
To mount a filesystem in Linux, you can use the mount command. Here's a step-by-step guide:

1. Identify the device

Use the lsblk or fdisk -l command to identify the device you want to mount. For example:

> lsblk

This will display all block devices connected to the system.

2. Create a mount point

Create a directory where you will mount the filesystem. For example:

> sudo mkdir /mnt/mydrive

3. Mount the filesystem

Use the mount command to mount the device to the directory. Replace <device> with the device name (e.g., /dev/sdb1) and <mount_point> with the directory you created:

> sudo mount <device> <mount_point>

Example:

> sudo mount /dev/sdb1 /mnt/mydrive

4. Verify the mount

Check if the device is mounted using:

> df -h

or

> mount | grep /mnt/mydrive

5. (Optional) Update /etc/fstab for persistent mounting

To automatically mount the device at boot, edit the /etc/fstab file:

> sudo nano /etc/fstab

Add an entry in the following format:

> /dev/sdb1 /mnt/mydrive ext4 defaults 0 0

Replace /dev/sdb1 with your device, /mnt/mydrive with your mount point, and ext4 with the filesystem type.

6. Unmounting the filesystem

When done, unmount the device using:

> sudo umount <mount_point>

Example:

sudo umount /mnt/mydrive

