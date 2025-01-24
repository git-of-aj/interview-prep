## What is a container ?
A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.
> A container is a bundle of Application, Application libraries required to run your application and the minimum system dependencies.
```
1. Resource Utilization: Containers share the host operating system kernel, making them lighter and faster than VMs. VMs have a full-fledged OS and hypervisor, making them more resource-intensive.

2. Portability: Containers are designed to be portable and can run on any system with a compatible host operating system. VMs are less portable as they need a compatible hypervisor to run.

3. Security: VMs provide a higher level of security as each VM has its own operating system and can be isolated from the host and other VMs. Containers provide less isolation, as they share the host operating system.

4. Management: Managing containers is typically easier than managing VMs, as containers are designed to be lightweight and fast-moving.
```

Containers are lightweight because they use a technology called containerization, which allows them to share the host operating system's kernel and libraries, while still providing isolation for the application and its dependencies.

files and folders in container `base image`:
```
    /bin: contains binary executable files, such as the ls, cp, and ps commands.

    /sbin: contains system binary executable files, such as the init and shutdown commands.

    /etc: contains configuration files for various system services.

    /lib: contains library files that are used by the binary executables.

    /usr: contains user-related files and utilities, such as applications, libraries, and documentation.

    /var: contains variable data, such as log files, spool files, and temporary files.

    /root: is the home directory of the root user.
```

- files and folders from host OS:
```
    The host's file system: Docker containers can access the host file system using bind mounts, which allow the container to read and write files in the host file system.

    Networking stack: The host's networking stack is used to provide network connectivity to the container. Docker containers can be connected to the host's network directly or through a virtual network.

    System calls: The host's kernel handles system calls from the container, which is how the container accesses the host's resources, such as CPU, memory, and I/O.

    Namespaces: Docker containers use Linux namespaces to create isolated environments for the container's processes. Namespaces provide isolation for resources such as the file system, process ID, and network.

    Control groups (cgroups): Docker containers use cgroups to limit and control the amount of resources, such as CPU, memory, and I/O, that a container can access.
```
- System calls are the mechanism through which a program (like a Docker container) interacts with the operating system’s kernel to request resources like CPU time, memory, file access, etc.
- Control groups, or cgroups, allow Docker (and the host system) to limit, prioritize, and monitor the resource usage (like CPU, memory, and disk I/O) of containers. This is useful for ensuring that no single container consumes too many resources.

## Docker - infrastructure plumbing
- To build Docker we have re-used large quantities of plumbing: Linux, Go, lxc, aufs, lvm, iptables, virtualbox, vxlan, mesos, etcd, consul, systemd… the list goes on.

## distributed vs Microservices
- A distributed system is a general term for any system where components are spread out across multiple machines or locations.
- Microservices is a specific architectural approach where an application is broken down into small, independent services, often running in a distributed system.

### **Comparison**: Distributed Systems vs. Microservices

| Feature               | **Distributed Systems**                         | **Microservices**                          |
|-----------------------|-------------------------------------------------|--------------------------------------------|
| **Scope**             | Encompasses any system where components are spread across machines or locations. | A specific approach to building applications where they are split into small, independent services. |
| **Purpose**           | Aims to enable multiple systems or machines to work together seamlessly. | Aims to split large applications into smaller, manageable services focused on business capabilities. |
| **Communication**     | Components interact via network protocols (e.g., HTTP, RPC). | Microservices interact via APIs or messaging (REST, gRPC, Kafka). |
| **Decentralization**  | A distributed system can be centralized or decentralized. | Microservices are inherently decentralized. Each service manages its own data and logic. |
| **Fault Tolerance**   | Provides fault tolerance through replication, redundancy, and data distribution. | Fault tolerance is inherent in microservices design—failure of one service doesn't affect the others. |
| **Scalability**       | Typically scalable by adding more nodes or machines. | Microservices scale by deploying more instances of individual services. |
| **Example**           | A distributed database or cloud infrastructure. | A set of services like a payment service, user service, etc., in a web application. |


