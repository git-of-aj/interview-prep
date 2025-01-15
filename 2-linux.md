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

---

These commands and flags are frequently used by system administrators to manage and troubleshoot Linux servers in production environments.
