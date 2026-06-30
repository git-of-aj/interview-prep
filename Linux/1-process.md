> Every program running on a Linux system is a process. When you open a browser, start a server, run a script, or execute a command, Linux creates a process to handle that task. Behind the scenes, the operating system constantly creates, schedules, pauses, and terminates processes to keep the system running smoothly.
A process is simply a running instance of a program. When you execute any command, Linux loads the program into memory and creates a process to execute it.
Every process has:
- A unique Process ID (PID)
- Memory allocation
- CPU usage
- Execution state
- Parent process
## Lifecycle
Linux uses processes to perform all tasks, from system operations to user applications.
1. Creation
A process begins when a program is executed. The system assigns a unique PID and allocates required resources.
2. Running
The process actively uses CPU and performs its task.
3. Waiting
The process may pause while waiting for input, resources, or system events.
4. Stopped
The process may be temporarily paused by the system or user.
5. Terminated
The process ends after completing its task or being stopped manually.
## States:
Common Linux process states include:
- Running - The process is actively using CPU
- Sleeping - Waiting for input or resource
- Stopped - Paused manually or by system
- Zombie - Completed but still listed in process table: It 1000s of zombie system may run out of PID to allocate
- Dead - Fully terminated
## Zombie vs orphan
**Zombie Process**
A process that has completed execution but still appears in the process table because its parent has not collected its status.

**Orphan Process**
A process whose parent has terminated. Linux automatically assigns such processes to the init/system process to maintain stability.

Understanding these helps in troubleshooting system issues.

## Process Priority and Scheduling
- Linux assigns priority to processes so critical tasks get CPU time first.
- Processes with higher priority receive more CPU time, while lower-priority processes run when resources are available.
- This ensures smooth system performance even when multiple programs run simultaneously.
