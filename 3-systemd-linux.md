- [docs](https://systemd.io/)

## define
Systemd is a tool in Linux that helps control how the computer starts up, runs programs, and manages services (like websites or databases). For DevOps engineers, it helps automate tasks, keep everything running smoothly, and make sure everything starts in the right order. This makes systems faster and more reliable.
- Systemd is an init system and service manager for Linux, handling everything from the boot process to managing services and system resources in userspace (where programs run outside the Linux kernel)
-  first process on boot (PID 1), and includes a command-line tool called `systemd-analyze security`, which checks if services are using security options and assigns each an “exposure” score.
> systemd-analyze security postgresql // any-systemd-service-name
## uses:
1. **Service Management**: Using `systemctl` to start, stop, or restart services (e.g., `systemctl restart nginx`).
2. **Automated Deployments**: Configuring `systemd` unit files to manage application lifecycle during CI/CD pipeline execution.
3. **Log Management**: Leveraging `journalctl` to monitor logs for troubleshooting or performance monitoring.
4. **Resource Control**: Setting resource limits (CPU, memory) for services via `systemd` configurations.

## Security 
[cheatsheet](https://gist.github.com/ageis/f5595e59b1cddb1513d1b425a323db04)
- [docs](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
- `Capabilities` in Linux are a way to split up the traditionally all-powerful root privileges into smaller, more specific permissions.
This means a process can have just the permissions it needs without full root access, enhancing security.
Currently, there are 40 capabilities available, ranging from very specific to broader permissions.
- To manage capabilities, the Linux kernel defines several "sets":
- These sets include:

1. Effective: capabilities currently in use by the process.

2. Permitted: capabilities the process is allowed to use.

3. Inheritable: capabilities that can be passed on to child processes.

In addition to these, there’s the bounding set (the maximum capabilities a process can hold) and the ambient set (capabilities actively in effect for the process).
> Capabilities Restriction in Systemd: We update the PostgreSQL Systemd unit service files to modify the capabilities it can use, improving host-level security.
```sh
[Service]

ExecStart=/usr/lib/postgresql/15/bin/postgres -D /var/lib/postgresql/data

CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_DAC_OVERRIDE

AmbientCapabilities=CAP_NET_BIND_SERVICE CAP_DAC_OVERRIDE
```
> In k8s:
```yml
apiVersion: v1

kind: Pod

metadata:

name: postgresql

labels:

app: postgresql

spec:

containers:

- name: postgres

image: postgres:15

ports:

- containerPort: 5432

securityContext:

capabilities:

add:

- NET_BIND_SERVICE

- DAC_OVERRIDE

readOnlyRootFilesystem: true

allowPrivilegeEscalation: false

runAsNonRoot: true

restartPolicy: Always
```
