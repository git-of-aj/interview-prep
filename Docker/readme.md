> The Open Container Initiative is an open governance structure for the express purpose of creating open industry standards around container formats and runtimes.
## What is a container ?
> Docker is a platform to build, ship and run distributed applications – meaning that it runs applications in a distributed fashion across many machines, often with a variety of hardware and OS configurations
A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another. A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.
> A container is a bundle of Application, Application libraries required to run your application and the minimum system dependencies.
- `dockerd` is the persistent process that manages containers. Docker uses different binaries for the daemon and client. [docker docs](https://docs.docker.com/reference/cli/dockerd/)
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
### Runc - [github](runC is available today at https://github.com/opencontainers/runc)
> it needs a sandboxing environment capable of abstracting the specifics of the underlying host (for portability), without requiring a complete rewrite of the application (for ubiquity), and without introducing excessive performance overhead (for scale).
`runC is a lightweight, portable container runtime. It includes all of the plumbing code used by Docker to interact with system features related to containers.`
- To build Docker we have re-used large quantities of plumbing: Linux, Go, lxc, aufs, lvm, iptables, virtualbox, vxlan, mesos, etcd, consul, systemd… the list goes on.
-  3 fundamental principles which we call “the Infrastructure Plumbing Manifesto”:

1. Whenever possible, re-use existing plumbing and contribute improvements back.

2. When you need to create new plumbing, make it easy to re-use and contribute improvements back. This grows the common pool of available components, and everyone benefits.

3. Follow the unix principles: several simple components are better than a single, complicated one.
- If you are deploying Docker in production: this makes Docker more ops-friendly. Because its underlying plumbing will be more cleanly separated, the platform becomes more modular; which in turn makes it easier to scale, easier to troubleshoot, easier to secure and easier to customize.
- If you want to integrate Docker with your favorite tool: because all plumbing exposes standard interfaces, each component becomes a potential integration point.
### [containerd](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
is a container runtime. In simple terms, containerd is a system that helps manage containers, which are lightweight, portable environments used to run software. It handles the basic operations like starting, stopping, and managing containers.

### What is containerd?
- **Containerd** is a piece of software that runs containers. Containers package up software, libraries, and settings so that they can run the same way anywhere.
- Think of it as a "manager" that helps run and manage these containers.

### What you’ll need:
1. **A Linux or Windows server**: Containerd is typically used on servers where software runs in containers.
2. **Docker (Optional)**: Although you don't need Docker to use containerd, it’s often used with it. Docker helps build and manage container images (basically the blueprints for containers).

### Installation Process:
To get started with containerd, you need to install it. Here's how to do that:
1. **Download and Install**:
   - You can install containerd on your server using a package manager (like `apt` for Ubuntu or `yum` for CentOS).
   - Once it's installed, you can check if it's running by typing commands in your terminal.

2. **Starting containerd**:
   - After installation, you'll want to start the containerd service. This service is like starting a program on your computer to get it running.
   - You can use a system tool (like `systemd` or `init`) to make sure containerd runs every time your server starts.

3. **Verifying Installation**:
   - After containerd is running, you can verify it's working by checking its status using a command like `ctr version`. This will tell you the version and confirm it’s installed correctly.

### Using containerd:
1. **Creating a container**:
   - The basic idea is that you "create" containers using containerd. To do this, you'd pull a container image (like a Docker image) and run it.
   
2. **Running a container**:
   - Once the image is downloaded, containerd will create a container from it. You can then run the container to start the application inside it.
   - It's like unzipping a file and running the app inside it, but more flexible.

## distributed vs Microservices
- A distributed system is a general term for any system where components are spread out across multiple machines or locations.
- Microservices is a specific architectural approach where an application is broken down into small, independent services, often running in a distributed system.

### **Comparison**: Distributed Systems vs. Microservices

| Feature               | **Distributed Systems**                         | **Microservices**                          |
|-----------------------|-------------------------------------------------|--------------------------------------------|
| **Scope**             | Encompasses any system where components are spread across machines or locations. | A specific approach to building applications where they are split into small, independent services. |
| **Purpose**           | **HA**: Aims to enable multiple systems or machines to work together seamlessly. | **Modularity**: Aims to split large applications into smaller, manageable services focused on business capabilities. |
| **Communication**     | Components interact via network protocols (e.g., HTTP, RPC). | Microservices interact via APIs or messaging (REST, gRPC, Kafka). |
| **Decentralization**  | A distributed system can be centralized or decentralized. | Microservices are inherently decentralized. Each service manages its own data and logic. |
| **Fault Tolerance**   | Provides fault tolerance through replication, redundancy, and data distribution. | Fault tolerance is inherent in microservices design—failure of one service doesn't affect the others. |
| **Scalability**       | Typically scalable by adding more nodes or machines. | Microservices scale by deploying more instances of individual services. |
| **Example**           | A distributed database or cloud infrastructure. | A set of services like a payment service, user service, etc., in a web application. |

## RAID
- RAID (Redundant Array of Independent Disks) is a way to organize multiple hard drives into a single array for data redundancy or performance improvements
- Dell R630 server = Compute: Handles tasks using its CPU, RAM, etc.
- RAID = Storage: Manages how multiple hard drives are configured for data storage and fault tolerance.
- RAID 1 for the Hyper-V host: Provides redundancy for the host OS.
- RAID 5 for VM storage: Efficient storage with fault tolerance for your VMs.
- Install Hyper-V on RAID 1, and create VMs on the RAID 5 array for both performance and protection.
