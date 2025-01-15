ssh -v -i test.pem aj@98.70.48.210

## process vs thread
In a Linux environment, processes can contain multiple threads. A process is created when you launch an application, and threads within the process allow it to perform tasks concurrently. Threads share the process’s memory, making them more lightweight than creating new processes.

Link:
A process is a container for threads.
Threads within the same process share resources like memory, file descriptors, etc.

```sh
Process:
  |
  |--> Independent memory space
  |--> Has its own resources
  |--> Slower due to isolation

Thread:
  |
  |--> Shares memory with other threads
  |--> Lighter and faster
  |--> Easier to communicate within process
```

## hard link vs symbolic
**Hard links** point to the same inode and share the same data blocks, allowing multiple filenames for one file. **Symbolic links** (symlinks) are shortcuts to another file, storing the target's path, and can link across filesystems. Both types reference the inode structure, which stores file metadata.

## PS
The command `ps -eLf` shows detailed information about processes and threads in Linux. Here's an explanation of the output:

### Columns:
- **UID**: User ID of the process owner.
- **PID**: Process ID, the unique identifier for a process.
- **PPID**: Parent Process ID, the process ID of the parent process.
- **LWP**: Light Weight Process ID, the thread ID (unique within a process).
- **C**: CPU utilization.
- **NLWP**: Number of threads in the process.
- **STIME**: Start time of the process.
- **TTY**: Terminal associated with the process (if applicable).
- **TIME**: CPU time consumed by the process.
- **CMD**: Command that started the process.

### Example Breakdown:
1. **First row**:
   - **PID 1**: The main init process (`/sbin/init`), started by the kernel during boot.
   - **LWP 1**: The init process has a single thread, so the LWP is the same as PID.
   - **NLWP 1**: The init process only has one thread.

2. **Second row**:
   - **PID 2**: A kernel thread (`kthreadd`), responsible for managing other kernel threads.
   - **LWP 2**: The `kthreadd` kernel thread has LWP 2.
   - **NLWP 1**: Only one thread for the `kthreadd` process. 

In summary, `ps -eLf` provides a detailed view of processes and their associated threads.

## set limits 
```sh
ulimit -a: View all resource limits.
ulimit -n <value>: Set max open files limit.
ulimit -s <value>: Set stack size limit.
ulimit can be used to monitor and control the resource usage for processes.
```
- Persistent changes:
To make changes persistent across reboots, you would need to edit system configuration files like /etc/security/limits.conf (for user limits) or use sysctl for kernel-level limits This file sets the resource limits for the users logged in via PAM. It does not affect resource limits of the system services.

Certainly! Here are some common Linux commands used by senior admins, along with their most popular flags and quick descriptions:

### 1. **`du` (Disk Usage)**
   - `-h` — Human-readable (KB, MB, GB)
   - `-s` — Summarize total usage for the directory
   - `--max-depth=N` — Limit depth of directory listing
   - `-a` — Show usage for all files
   - `-c` — Show a grand total

   **Example**: `du -sh /var/log`
## IP a
The `ip a` output shows network interfaces and their details:

1. **lo (Loopback Interface)**:
   - **IP**: 127.0.0.1 (IPv4) and ::1 (IPv6).
   - **Status**: UP, used for internal communication.

2. **eth0 (Ethernet Interface)**:
   - **IP**: 10.0.0.4/24 (IPv4) and fe80::222:48ff:fe6e:8ade/64 (IPv6).
   - **Status**: UP, connected to a network.

## Traceroute 8.8.8.8
> The output of traceroute showing * * * for each hop means that the traceroute request timed out or the response was not received within the expected time. possibly due to firewall rules or network configurations.
Firewalls or network security devices may be blocking ICMP Echo Requests (used by traceroute) or not responding to them. This is common in corporate networks, data centers, or even on the internet.
## STAT
In Linux, files have three types of timestamps: **atime**, **mtime**, and **ctime**. These represent different aspects of file access and modification.

### 1. **atime (Access Time)**:
- **Definition**: The last time a file was accessed (read).
- **Changed when**: You read a file, for example using `cat`, `less`, or `open` in a program.
- **Command to view**: 
  ```bash
  stat filename
  ```
  Example output:
  ```
  Access: 2025-01-15 09:35:22.000000000 -0500
  ```

### 2. **mtime (Modification Time)**:
- **Definition**: The last time the content of the file was modified.
- **Changed when**: You edit a file (e.g., using `vi`, `nano`, `echo`).
- **Command to view**: 
  ```bash
  stat filename
  ```
  Example output:
  ```
  Modify: 2025-01-15 09:10:01.000000000 -0500
  ```

### 3. **ctime (Change Time)**:
- **Definition**: The last time the file's metadata or content was changed (e.g., permission changes, ownership change, or content modification).
- **Changed when**: You change file permissions with `chmod`, change ownership with `chown`, or modify the file.
- **Command to view**:
  ```bash
  stat filename
  ```
  Example output:
  ```
  Change: 2025-01-15 09:20:15.000000000 -0500
  ```

### Key Commands:

- **`stat filename`**: Shows all three timestamps (atime, mtime, ctime).
- **`touch filename`**: Updates both `atime` and `mtime` to the current time. If the file doesn't exist, it creates an empty file.
  ```bash
  touch filename
  ```
- **`date`**: Displays the current system time, useful for comparison.
  ```bash
  date
  ```

### Summary of Differences:
- **atime**: Last access (read) time.
- **mtime**: Last modification (content change) time.
- **ctime**: Last change (metadata or content change) time.

By understanding these timestamps, you can better track file access and changes in your system, which is helpful for auditing and troubleshooting.
---

### 2. **`df` (Disk Free Space)**
   - `-h` — Human-readable (KB, MB, GB)
   - `-T` — Show filesystem type
   - `-i` — Show inode usage
   - `--total` — Show a grand total at the end

   **Example**: `df -hT`

---

### 3. **`ls` (List Files)**
   - `-l` — Long listing format (permissions, owner, etc.)
   - `-a` — Include hidden files
   - `-t` — Sort by modification time
   - `-r` — Reverse order
   - `-h` — Human-readable sizes
   - `-S` — Sort by file size

   **Example**: `ls -ltr /var/log`

---

### 4. **`ps` (Process Status)**
   - `-e` — Show all processes
   - `-f` — Full-format listing (detailed)
   - `-u <user>` — Show processes for a specific user
   - `-aux` — Show all processes (even those without a terminal)

   **Example**: `ps aux`

---

### 5. **`top` (Task Manager)**
   - `-u <user>` — Show processes for a specific user
   - `-p <pid>` — Show a specific process
   - `-n <number>` — Limit iterations (number of updates)

   **Example**: `top -u www-data`

---

### 6. **`find` (Find Files)**
   - `-name <pattern>` — Search for files by name
   - `-type <type>` — Search by file type (e.g., f = regular file, d = directory)
   - `-size <+/-size>` — Search by size (e.g., `+100M`)
   - `-exec <command>` — Execute a command on matching files
   - `-mtime <n>` — Search by modification time

   **Example**: `find /var/log -name "*.log" -size +100M`

---

### 7. **`grep` (Search Text)**
   - `-r` — Recursively search directories
   - `-i` — Case-insensitive search
   - `-l` — Show filenames only (not matched text)
   - `-n` — Show line numbers
   - `-v` — Invert match (show lines that don’t match)

   **Example**: `grep -r "error" /var/log`

---

### 8. **`chmod` (Change Permissions)**
   - `+x` — Add execute permission
   - `-x` — Remove execute permission
   - `777` — Full permissions for owner, group, others

   **Example**: `chmod 755 /path/to/script.sh`

---

### 9. **`chown` (Change Ownership)**
   - `-R` — Recursively change ownership
   - `user:group` — Specify new owner and group

   **Example**: `chown -R user:group /path/to/dir`

---

### 10. **`systemctl` (Service Manager)**
   - `start` — Start a service
   - `stop` — Stop a service
   - `restart` — Restart a service
   - `status` — Show the service status
   - `enable` — Enable service to start at boot
   - `disable` — Disable service from starting at boot

   **Example**: `systemctl restart nginx`

---

### 11. **`service` (Service Management)**
   - `start` — Start a service
   - `stop` — Stop a service
   - `status` — Show service status

   **Example**: `service apache2 restart`

---

### 12. **`tar` (Archiving)**
   - `-c` — Create a new archive
   - `-x` — Extract from an archive
   - `-v` — Verbose output (show file names)
   - `-f` — Specify the archive file
   - `-z` — Compress with gzip

   **Example**: `tar -czvf backup.tar.gz /path/to/dir`

---

### 13. **`wget` (Download Files)**
   - `-r` — Recursive download
   - `-P <dir>` — Specify download directory
   - `-c` — Continue downloading if interrupted
   - `-N` — Only download newer files

   **Example**: `wget -r -P /path/to/save http://example.com`

---

### 14. **`curl` (Transfer Data)**
   - `-O` — Save output to a file
   - `-L` — Follow redirects
   - `-I` — Fetch headers only
   - `-u` — Specify username:password for HTTP authentication

   **Example**: `curl -O http://example.com/file.tar.gz`

---

### 15. **`scp` (Secure Copy)**
   - `-r` — Recursively copy directories
   - `-P` — Specify a port (default is 22)
   - `-i` — Specify an identity (private key)

   **Example**: `scp -r /local/dir user@remote:/path/to/dir`

---

### 16. **`rsync` (Remote Sync)**
   - `-a` — Archive mode (preserve permissions, symlinks, etc.)
   - `-v` — Verbose output
   - `-z` — Compress files during transfer
   - `--delete` — Delete files on the destination that no longer exist on the source

   **Example**: `rsync -avz /local/dir user@remote:/path/to/dir`

---

### 17. **`netstat` (Network Statistics)**
   - `-t` — Show TCP connections
   - `-u` — Show UDP connections
   - `-l` — Show only listening ports
   - `-p` — Show the process associated with each socket

   **Example**: `netstat -tulnp`

---

### 18. **`iptables` (Firewall Management)**
   - `-L` — List all rules
   - `-A` — Append a rule
   - `-D` — Delete a rule
   - `-F` — Flush all rules

   **Example**: `iptables -L`

---

### 19. **`uname` (System Information)**
   - `-r` — Kernel version
   - `-a` — All system information (kernel, hostname, etc.)
   - `-m` — Machine hardware name (e.g., x86_64)

   **Example**: `uname -a`

---

### 20. **`history` (Command History)**
   - `-c` — Clear history
   - `-d <line_number>` — Delete a specific line from history

   **Example**: `history -c`

Here’s a brief explanation of each command:

1. **`whoami`**: Displays the current logged-in user's username.
   ```bash
   whoami
   ```

2. **`who am i`**: Displays the current user’s login session details, including the terminal and IP address.
   ```bash
   who am i
   ```

3. **`who`**: Shows information about users currently logged into the system, including their terminal, login time, and IP.
   ```bash
   who
   ```

4. **`id`**: Displays the user ID (UID), group ID (GID), and groups the user belongs to.
   ```bash
   id
   ```

5. **`w`**: Shows who is logged in and their activity (e.g., idle time, processes being run).
   ```bash
   w
   ```

6. **`uptime`**: Displays how long the system has been running, along with the current time, load averages, and number of users.
   ```bash
   uptime
   ```

7. **`last`**: Shows the list of recent logins, reboots, and shutdowns.
   ```bash
   last
   ```

These commands are helpful for monitoring users, system uptime, and login activity.

---

These commands and flags are frequently used by system administrators to manage and troubleshoot Linux servers in production environments.
