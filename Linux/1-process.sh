1. pidof or pgrep -af or ps aux | grep 'App-Name' to get PID

2. aj@sql:~$ ps -fp 2142
UID          PID    PPID  C STIME TTY          TIME CMD
aj          2142    1313  0 19:21 pts/0    00:00:00 python3 app.py

# only ps gives very little result

- top does not show every process at the top of the list—it sorts primarily by CPU usage by default.
- (Type a capital L.)
Enter: PID or command you wanna find 
- top -p <PID> : it'll show only that PID
