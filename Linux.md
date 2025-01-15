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

### FILE SYSTEM 
Good question! Specifying the filesystem type (ext4, ntfs, xfs, etc.) is optional in many cases because the mount command can automatically detect it. However, there are situations where explicitly specifying the filesystem type is necessary:

When you might need to specify the filesystem type:

1. Unsupported or uncommon filesystems: If the kernel or mount cannot automatically detect the type, you'll need to specify it.


2. Forcing a specific type: If the device has multiple partitions or metadata confusing the auto-detection.


3. Mounting non-standard filesystems: For example, mounting a Windows NTFS drive or a FAT32 USB drive.


4. If auto-detection fails: Sometimes, the system might not correctly identify the filesystem, especially with corrupted or unusual partitions.



How to specify the filesystem type:

Use the -t option in the mount command to specify the filesystem type explicitly:

> sudo mount -t ext4 /dev/sdb1 /mnt/mydrive

How to determine the filesystem type:

Use the blkid command or lsblk -f to identify the filesystem type:

> sudo blkid /dev/sdb1

or

> lsblk -f

Example Scenarios:

1. Ext4 filesystem:

> sudo mount -t ext4 /dev/sdb1 /mnt/mydrive


2. NTFS filesystem (commonly used in Windows):

sudo mount -t ntfs-3g /dev/sdb1 /mnt/mydrive


3. FAT32 filesystem (for USB drives):

> sudo mount -t vfat /dev/sdb1 /mnt/mydrive



If you’re unsure of the type, using blkid or lsblk -f beforehand helps avoid errors.

## attach new disk -- without formatting 
If you want to attach a disk to a new computer for reuse or disaster recovery (DR) without erasing its data, you don’t need to format or recreate the filesystem. Here’s how you can achieve that safely:


---

Steps to Detach and Attach a Disk Without Data Loss

On the Original System:

1. Unmount the Disk Properly

Before detaching a disk, ensure it’s unmounted to prevent data corruption.

Command:

> sudo umount /dev/sdX

Replace /dev/sdX with the appropriate disk or partition name (e.g., /dev/sdb1).



2. Check for Open File Handles (Optional)

Ensure no process is using the disk:

> sudo lsof | grep /dev/sdX

Kill any processes using the disk if necessary.



3. Power Off the System

Safely shut down the system or stop power to the disk if it's hot-swappable.

If the disk is part of a RAID or LVM setup, ensure it's cleanly removed.



4. Physically Detach the Disk

Disconnect the disk's power and data cables carefully

On the New System:

1. Physically Connect the Disk

Attach the disk to the new computer using the same interface (SATA, NVMe, USB, etc.).



2. Identify the Disk

Boot the new system and use lsblk or fdisk -l to identify the disk.
Example:

> lsblk



3. Mount the Disk

Locate the partition and mount it to a directory.
Example:

> sudo mount /dev/sdX1 /mnt/newdisk



4. Verify Data Access

Check that all data is intact by listing the contents of the mounted directory:

> ls /mnt/newdisk





---

Key Notes for DR and Data Reuse

1. Ensure Compatible Filesystems

If the filesystem isn’t supported on the new system (e.g., an ext4 disk on Windows), install the necessary drivers or use tools like ext2fsd for Windows.



2. Use UUID for Mounting

To avoid mounting issues, use the UUID to identify the disk instead of device names like /dev/sdb.
Example:

> sudo blkid /dev/sdX1
> sudo mount UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx /mnt/newdisk



3. Avoid Formatting the Disk

Formatting erases all data. Use the disk as-is unless you’re sure data is backed up elsewhere.



4. For Encrypted Disks

If the disk is encrypted (e.g., using LUKS), you’ll need the decryption key to access the data on the new system.



5. For Bootable Disks

If the disk contains an operating system and you want to boot from it on the new system, ensure BIOS/UEFI settings are configured to boot from the disk.

## Why formatting needed 
Formatting is optional if the disk is already prepared and contains a valid filesystem compatible with your system. However, there are specific scenarios where formatting is necessary or recommended. Here's why:


---

Why Formatting is Done

1. Prepare a New Disk for Use

A new disk has no filesystem, making it inaccessible. Formatting creates a usable filesystem like ext4, NTFS, or FAT32.

Without formatting, the system cannot store or organize files on the disk.


2. Change or Upgrade the Filesystem

To switch to a different filesystem type for compatibility or performance reasons (e.g., changing from NTFS to ext4 for better Linux compatibility).


3. Clean the Disk

To remove all existing data, ensuring a clean slate for a fresh start or security purposes (e.g., before repurposing or selling a disk).


4. Repair a Corrupted Filesystem

If a disk’s filesystem is damaged or corrupted, formatting can restore it to a working state (though data is erased).


5. Optimize Performance

Older filesystems may not utilize the disk's full potential (e.g., larger storage or SSD optimizations). Formatting with a modern filesystem like ext4 or XFS can improve performance.


6. Partition Alignment

When partitioning and formatting modern disks (like SSDs), proper alignment can improve read/write performance.


7. Remove Old Partition Tables

Formatting erases old partition structures or data remnants that might interfere with the disk’s operation.



---

When You Should Avoid Formatting

If the disk contains important data you want to preserve.

When the disk is already properly formatted and compatible with the intended system or device.



---

What Happens During Formatting

1. Low-Level Formatting: (Rarely done today) Physically prepares the disk by defining tracks and sectors.


2. High-Level Formatting: Creates a new filesystem and writes metadata (file allocation table, inodes, etc.) for file organization.




---

Practical Scenarios

1. Fresh Disk Installation:

A new external HDD is purchased. Formatting prepares it to store files.



2. OS Installation:

A new OS is installed, requiring a specific filesystem (ext4 for Linux, NTFS for Windows).



3. Cross-Platform Use:

A disk formatted as ext4 is reformatted to NTFS for use in a Windows system.

### Partitions 
Physical Disk (e.g., /dev/sda):

- Partition 1 (/dev/sda1): Holds the operating system (Linux) with ext4 filesystem.

- Partition 2 (/dev/sda2): Contains personal files with NTFS for cross-platform access.

- Partition 3 (/dev/sda3): Swap partition used for virtual memory.

Physical Disk:

The entire disk is a single hardware unit, like an HDD, SSD, or USB drive.



2. Partitions:

A physical disk is divided into smaller, logical sections called partitions.

Each partition is treated as an independent storage area by the operating system.



3. Filesystem:

Each partition can have its own filesystem (e.g., ext4, NTFS) and hold different data.

------

![image](https://github.com/user-attachments/assets/73bfc4bb-3ab6-4833-939d-c24051e89b69)

![image](https://github.com/user-attachments/assets/c9935fbd-50bc-4151-abd6-787232f4ff3a)

- Process Id: It's a unique Id provided to all processes. It is used to identify a running process uniquely throughout the computer until the process ends.

- INODE: It's a unique name provided to all files by the operating system. All inodes have a unique inode number in a file system. INODE stores many details about files, including the number of links, access mode, file type, file size, ownership, etc.
- Swap space is used to specify a space which is used by Linux to hold some concurrent running program temporarily. It is used when RAM does not have enough space to hold all programs that are executing.
swap space is a space on the hard disk used when the RAM or physical memory amount is full. It's a replacement for physical memory. Its primary function is to replace disk space for memory when actual RAM doesn't have sufficient space to hold every program that is running, and more space is needed. In other words, it can be used as a RAM extension by Linux. Swap partition size -- double the amount of RAM or physical memory available in the system. 

![image](https://github.com/user-attachments/assets/4eb23d5e-b139-421e-8fe0-6d6f34ea9315)
1. New/Ready: A new process is made and is ready to execute.
2. Running: The process is being run.
3. Blocked/Wait: The process waits for input through the user, and if it does not have resources to execute, such as input, file locks, and memory, it can remain in a blocked or waiting state.
4. Completed/Terminated: The process has been terminated by the operating system or finished the execution.
5. Zombie: The process is aborted, but information related to the process is still available and is available within the process table








