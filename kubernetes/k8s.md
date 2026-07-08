## Tips 
- [slim vs alpine vs default images in dockerHub](https://forums.docker.com/t/differences-between-standard-docker-images-and-alpine-slim-versions/134973/2). Incase of `Nginx` its dockerhub repo says slim is bare-min package. practically checked:
```sh
REPOSITORY   TAG                      IMAGE ID       CREATED              SIZE
default      latest                   b4f9d75eb6a8   7 seconds ago        161MB
alpine       latest                   cc3560d7e909   37 seconds ago       103MB
slim         latest                   e34d0f178f4c   About a minute ago   12.7MB
nginx        latest                   1a1e63136420   44 hours ago         161MB
nginx        stable-alpine3.23-perl   54244b5140f2   7 days ago           103MB
nginx        stable-alpine3.23-slim   f1b084fe8a3b   7 days ago           12.6MB
```
- Kubernetes Configuration Best Practices for additional information on writing YAML configuration files https://kubernetes.io/blog/2025/11/25/configuration-good-practices/ 

## Basics
- A Kubernetes object is a "record of intent"--once you create the object, the Kubernetes system will constantly work to ensure that the object exists. Means anything you create - a pod, service, deployment they all are objects.

https://kubernetes.io/docs/concepts/overview/working-with-objects/

- CRUD via k8s api https://kubernetes.io/docs/concepts/overview/kubernetes-api/

- Objects that continue to exist in the Kubernetes system even if nothing is actively using them, and they store the desired state of the cluster.

Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster.

- The spec is what you want the object to be (its desired state), and the status is what the object currently is. Kubernetes control plane constantly works to make the status match the spec.


> In the manifest (YAML or JSON file) for the Kubernetes object you want to create, you'll need to set values for the following fields:

1. apiVersion - Which version of the Kubernetes API you're using to create this object

2. kind - What kind of object you want to create

3. metadata - Data that helps uniquely identify the object, including a name string, UID, and optional namespace

4. spec - What state you desire for the object

YAML =converted=> JSON in background

how to write object yaml here: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/

## Advanced Terms:
- controllers are control loops that watch the state of your cluster, then make or request changes where needed. Each controller tries to move the current cluster state closer to the desired state. [Docs](https://kubernetes.io/docs/concepts/architecture/controller/)

#### Match and Lables:
- Labels are key/value pairs that are attached to objects (like pods, services)
- labels do not provide uniqueness. In general, we expect many objects to carry the same label(s).
- Labels can be attached to objects at creation time and subsequently added and modified at any time. 
- Labels allow for efficient queries and watches and are ideal for use in UIs and CLIs. Non-identifying information should be recorded using annotations
```yml
# using label to schedule on node with gpu only
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: "registry.k8s.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:
    accelerator: nvidia-tesla-p100
```
Label Types:
1. Equality (= or == / !=)
2. Set (in,notin and exists)
> environment=production is equivalent to environment in (production); similarly for != and notin. Set-based requirements can be mixed with equality-based requirements. For example: partition in (customerA, customerB),environment!=qa

**Services use label selector**:
```yml
selector:
  component: redis
```


### Services
> Services allow your applications to receive traffic. Though each Pod has IP but that's inaccesible from outside
- A Kubernetes Service is an abstraction layer which defines a logical set of Pods and enables external traffic exposure, load balancing and service discovery for those Pods.
`Loadbalancer => NodePort ==> ClusterIP [superset => subset]`
- clusterip : use to expose pods with a permanent internal ip from pool of IP addresses that your cluster has reserved for that purpose. `NOT from VNET`. AKS has `Service CIDR` for this.
- nodeport (range: 3000 to 32767)  // user > nodeport > port (of service) > targetport (of running container)
- load balancer: only if using any cloud provider
- externalnames: 

## Workload Objects

### 1. Deployments (for stateless application)
```
kubectl rollout status deployment/nginx-deployment
```
- Deployment is interchangeable and can be replaced if needed. (Deployments are a replacement for the legacy ReplicationController API).
- Deployment (and, indirectly, ReplicaSet), the most common way to run an application on your cluster
- A deployment can even have multiple containers, though not recommended (then frontend, backend all scale together.. one kills OOM other suffers as well)
- Only sidecar containers are the usecase of multiple containers in a pod.
```yml
spec:
      containers:
        - name: frontend
          image: ghcr.io/example/frontend:1.2.3
          ports:
            - containerPort: 3000
        - name: Backend
          image: 
```

### 2. Statefulset (where all pods run same app code, connect to PV)
- run a StatefulSet that associates each Pod with a PersistentVolume. If one of the Pods in the StatefulSet fails, Kubernetes makes a replacement Pod that is connected to the same PersistentVolume.
- Real-World Example: A Database (like MongoDB or MySQL).
- Behavior: Each Pod gets a unique, persistent ID (e.g., db-0, db-1). If db-0 dies, Kubernetes replaces it with a new Pod that attaches to the exact same storage disk so the data isn't lost
### Deamonset:
- Auto added to each node
- Each Pod in a DaemonSet performs a role similar to a system daemon on a classic Unix / POSIX server
- Real-World Example: Logging (Fluentd) or Monitoring (Prometheus Node Exporter).
- Behavior: It ensures that every Node in your cluster runs a copy of this Pod. If you add a Node to the cluster, the DaemonSet automatically pops a Pod onto it. If you have a special "Kitchen Floor" (a Node with a GPU), you might use a DaemonSet to put a "Fire Suppressor" (GPU Driver) only on that specific floor.

`Note:You must specify an appropriate selector and Pod template labels in a Deployment (in this case, app: nginx).Do not overlap labels or selectors with other controllers (including other Deployments and StatefulSets). Kubernetes doesn't stop you from overlapping, and if multiple controllers have overlapping selectors those controllers might conflict and behave unexpectedly.`

### Pods 
> analogous to vm running multiple apps. A Pod gives all its containers the same IP, port space, and network namespace—letting them communicate via localhost and shared IPC—while communication with other Pods happens only through IP networking.
is a group of one or more containers, with shared storage and network resources, and a specification for how to run the containers.
>>>> pod = single instance of a given application.

- horizontal scaling of app = add more pods

> As well as application containers, a Pod can contain init containers that run during Pod startup. You can also inject ephemeral containers for debugging a running Pod

**Note:**

- You need to install a container runtime into each node in the cluster so that Pods can run there.

- A Pod is similar to a set of containers with shared namespaces and shared filesystem volumes.

***Used as:***

 ***"one-container-per-Pod" most common -  Kubernetes manages Pods rather than managing the containers directly.***

***\[adv use case - sidecar / init containers]:https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers***

<i>by design: Pods are designed as relatively ephemeral, disposable entities.Usually you don't need to create Pods directly, even singleton Pods. Instead, create them using workload resources such as Deployment or Job. If your Pods need to track state, consider the StatefulSet resource.</i>

**Note:**

- Restarting a container in a Pod should not be confused with restarting a Pod. A Pod is not a process, but an environment for running container(s). A Pod persists until it is deleted.

- the Pod remains on that node until the Pod finishes execution, the Pod object is deleted, the Pod is evicted for lack of resources, or the node fails.

- In Kubernetes v1.35, .spec.os.name doesn’t influence scheduling, so you must use correct kubernetes.io/os node labels and Pod nodeSelector to ensure Pods land on compatible OS nodes, with the field also helping Pod Security Standards apply OS‑appropriate policies.

- or container image is for specific os kernel.. then use it

*if a Node fails, a controller notices that Pods on that Node have stopped working and creates a replacement Pod. The scheduler places the replacement Pod onto a healthy Node.*

***workload \[workload = app running on k8s] resources that manage one or more Pods:***

***Deployment***

***StatefulSet***

***DaemonSet***

- when the Pod template for a workload resource is changed, the controller creates new Pods based on the updated template instead of updating or patching the existing Pods.

- can update running pod but not recommended: https://kubernetes.io/docs/concepts/workloads/pods/#pod-update-and-replacement

👉 A Pod receives one unique IPv4 address and, if the cluster supports it, one unique IPv6 address.

#### container probe

A probe is a diagnostic performed periodically by the kubelet on a container. To perform a diagnostic, the kubelet can invoke different actions:

- ExecAction (performed with the help of the container runtime)

- TCPSocketAction (checked directly by the kubelet)

- HTTPGetAction (checked directly by the kubelet)

*CrashLoopBackOff* : when a container in the Pod fails to start properly and then continually tries and fails in a loop.

The CrashLoopBackOff can be caused by issues like the following:

- Application errors that cause the container to exit.

- Configuration errors, such as incorrect environment variables or missing configuration files.

- Resource constraints, where the container might not have enough memory or CPU to start properly.

- Health checks failing if the application doesn't start serving within the expected time.

- Container liveness probes or startup probes returning a Failure result as mentioned in the probes section.

# [continue here](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-restarts)

- [init containers: Run b4 app start](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#examples)
- [sidecar containers: Run parallely to app](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)
- [ephermal container: Pod to accomplish user-initiated actions such as troubleshooting](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/)
> distroless images enable you to deploy minimal container images that reduce attack surface and exposure to bugs and vulnerabilities. Since distroless images do not include a shell or any debugging utilities, it's difficult to troubleshoot distroless images using kubectl exec alone.When using ephemeral containers, it's helpful to enable process namespace sharing so you can view processes in other containers

### Container runtime

Kubernetes and Amazon EKS have started using containerd as the default runtime from version 1.24.

A container runtime is software that executes containers and manages container images on a node. The runtime helps abstract away system calls or OS-specific functionality to run containers on Linux or Windows. For Linux node pools, containerd is used on Kubernetes version 1.19 and higher. For Windows Server 2019 and 2022 node pools, containerd is generally available and is the only runtime option on Kubernetes version 1.23 and higher.[ms docs](https://learn.microsoft.com/en-us/azure/aks/core-aks-concepts)

https://kubernetes.io/docs/setup/production-environment/container-runtimes/

## Deployment (Detail):
- manage pods (by change deployments > that changes replicaset > changes pods)
- spin new, rollback to old version, scale up/down [Docs](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#use-case)
- Note:In API version apps/v1, a Deployment's label selector is immutable after it gets created.
> For example, suppose you create a Deployment to create 5 replicas of nginx:1.14.2, but then update the Deployment to create 5 replicas of nginx:1.16.1, when only 3 replicas of nginx:1.14.2 had been created. In that case, the Deployment immediately starts killing the 3 nginx:1.14.2 Pods that it had created, and starts creating nginx:1.16.1 Pods. It does not wait for the 5 replicas of nginx:1.14.2 to be created before changing course
`Note: when you roll back to an earlier revision, only the Deployment's Pod template part is rolled back not replicas`
- *By Default Maz 25% Pod unavaialble during update*

## Namespace
- cluster vide objects
- namespace scoped
```sh
# In a namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false
```
- if Namespaces are intended for use in environments with many users spread across multiple teams, or projects => yes **ELSE** no
- use labels to distinguish resources within the same namespace.
- [K8s docs recommends](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#initial-namespaces): For a production cluster, consider not using the default namespace. Instead, make other namespaces and use those.
- When you create a Service, it creates a corresponding DNS entry. This entry is of the form `<service-name>.<namespace-name>.svc.cluster.local`, which means that if a container only uses `<service-name>`,it will resolve to the service which is local to a namespace.
- Via Pod IP different namespace resource can communicate, but IP is ephermal hence service.
> **Caution:** If a Kubernetes namespace has the same name as a public domain (e.g., “github.com”), it can override real DNS.
DNS lookups without a trailing dot will prefer the internal service.
This can cause apps to talk to the wrong service.
- You create a namespace called:
`google.com`Inside it, you create a service called:
`docs`.
- Now the service’s full DNS name inside Kubernetes becomes:
`docs.google.com.svc.cluster.local` not correct one.

## Taints and Tolerations
> Node affinity is a property of Pods that attracts them to a set of nodes. Taints are the opposite -- they allow a node to repel a set of pods
- if taints changed after scheduling pod can get evicted.... but node affinity after change doesn't get effected
## Node Affinity
- RequiredDuringSchedulingIgnoredDuringExecution: Pod Only spins if exact match found
- PreferredDuringSchedulingIgnoredDuringExecution: Even if EXACT Label Match not found, still scheduled.
a. node label changed.. Running Pods not impacted.. only new ones impacted. Just Opp in RequiredDuringSchedulingIgnoredDuringExecution
- NOdeAffinity more powerful than taints

### Container Storage Interface (CSI) Driver - decouple storage from core code
> **CSI = a standard that lets any storage vendor plug their block/file storage into Kubernetes 🔌 without changing K8s core code [They don't wait for K8s release cycle for bug fix], making storage options more flexible, secure, and reliable 🚀.**
![](https://devopscube.com/content/images/2025/03/secret-store-csi-driver_2-1.jpg)

Secrets Store CSI Driver is a Kubernetes driver deployed as a DaemonSet. It integrates secrets stored in external secrets management tools and mounts secrets on pods as a volume.

# *************** AKS  ***************
- `Fleet Manager`: COmmon Dashboard to monitor Join AKS clusters across regions and subscriptions, as well as Arc-enabled Kubernetes clusters (preview) across clouds and on-premises as member clusters.
## ================ copilot ===========
Absolutely — here’s a **complete, revision-friendly diagram** of the **Pod lifecycle** exactly covering **everything in your transcript** (no missing steps). I’m giving you:

1.  **Main end-to-end lifecycle flow (control-plane → node → states)**
2.  **State machine (Pending → ContainerCreating → Running → …)**
3.  **Health probes + failure path**
4.  **Hooks + init containers placement**
5.  **Troubleshooting: why “Pending” stays long + where to check events**

***

> The group of pods that comprise the application is specified using a label selector, the same as the one used by the application's controller (deployment, stateful-set, etc).

### Pod Disruption: 
> Pod down due to unavoidable (involuntary) or man made (voluntary) causes.
All causes listed [here in k8s docs](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions)

-  you can create a PodDisruptionBudget (PDB) for each application. A PDB limits the number of Pods of a replicated application that are down simultaneously from voluntary disruptions.
- `kubectl drain`: to bring down a node (for upgrades) but if PDB is applied and not enough cluster to spin pod, this request will block. 


### extra

Parsing = turning raw text into structured meaning a computer can work with.

Why Do We Need Serialization?

Because computers store data in RAM in complex ways (pointers, references, object graphs) that cannot be directly saved or transmitted.

Serialization provides:



a universal representation,

cross-platform sharing, and

interoperability between different languages and systems.



Data serialization exists because we need a universal way to store, send, and reconstruct data.

There are many formats because each one is optimized for different priorities:



XML → structure \& metadata

JSON → simplicity \& readability

Protobuf → performance \& efficiency



=========== Gemini =========

Actually, they absolutely \*\*do\*\* use TCP, and they use \*\*Protobuf\*\* extensively!



When you look at Kubernetes from the outside (using `kubectl`), it looks like a standard REST API using JSON. But "under the hood," inside the cluster, it's a high-performance machine that switches to more efficient gears.



Here is the breakdown of how they actually talk:



---



\## 1. The Transport: It's all TCP



Every bit of communication between Kubernetes components happens over \*\*TCP connections\*\*, almost always wrapped in \*\*TLS (HTTPS)\*\* for security.



\* \*\*Persistent Connections:\*\* Components like the Kubelet or Scheduler don't just send one message and hang up. They maintain "Long-Running" TCP connections (often using \*\*HTTP/2\*\*) so they can "Watch" for changes in real-time without the overhead of constantly reconnecting.



---



\## 2. The Language: Protobuf vs. JSON



Kubernetes is bilingual. It speaks both JSON and Protobuf, but it picks the best one for the job:



\* \*\*For Humans (External):\*\* When you run `kubectl get pods`, the API Server usually sends back \*\*JSON\*\*. It’s text-based, easy for you to read, and easy for web browsers to understand.

\* \*\*For Components (Internal):\*\* When the \*\*Kubelet\*\* talks to the \*\*API Server\*\*, or the \*\*Scheduler\*\* checks for updates, they use \*\*Protobuf (Protocol Buffers)\*\*.



\### Why Protobuf?



Imagine sending a physical letter (JSON) vs. a compressed ZIP file (Protobuf).



\* \*\*Smaller Size:\*\* Protobuf is binary, so it's much smaller than the text-heavy JSON. This saves massive amounts of bandwidth when you have 5,000 nodes talking at once.

\* \*\*Faster Speed:\*\* Computers can "read" (parse) binary data much faster than they can read human text.



---



\## 3. The Special Cases (gRPC)



While most of the "main" components talk via a REST-like API (even if they use Protobuf internally), some specific parts of Kubernetes use \*\*gRPC\*\* (which is built on top of HTTP/2 and Protobuf):



\* \*\*CRI (Container Runtime Interface):\*\* When the Kubelet tells Docker or containerd to "Start a container," it uses a \*\*gRPC\*\* call.

\* \*\*CSI (Container Storage Interface):\*\* When your app needs a hard drive attached, it uses \*\*gRPC\*\*.

\* \*\*etcd:\*\* The "Master Ledger" uses \*\*gRPC\*\* for its internal communication and for talking to the API Server.



---



\## 📊 Summary Table



| Connection | Protocol | Data Format |

| --- | --- | --- |

| \*\*You → API Server\*\* | HTTPS (TCP) | JSON / YAML |

| \*\*Kubelet → API Server\*\* | HTTPS (TCP) | \*\*Protobuf\*\* |

| \*\*API Server → etcd\*\* | \*\*gRPC (TCP)\*\* | \*\*Protobuf\*\* |

| \*\*Kubelet → Container Engine\*\* | \*\*gRPC (Unix Socket/TCP)\*\* | \*\*Protobuf\*\* |



\*\*The Trick to Remember:\*\*

If a human is involved, it’s probably \*\*JSON\*\*. If it's just two machines talking to keep the cluster alive, it's almost certainly \*\*Protobuf over a persistent TCP connection.\*\*



Would you like to see the actual `curl` command to ask the API Server for a Protobuf response instead of the usual JSON?

----

Communication in a Kubernetes cluster isn't a free-for-all; it’s a highly structured hierarchy. To visualize it easily, remember this rule: \*\*The API Server is the Hub.\*\*



Almost no component talks directly to another. Instead, they all talk to the "Front Desk" (API Server), which then updates the "Ledger" (etcd).



---



\## 📞 The Communication Flow



\### 1. The Hub-and-Spoke Model



Think of the \*\*kube-apiserver\*\* as a central switchboard.



\* \*\*The Control Plane components\*\* (Scheduler, Controller Manager) "watch" the API Server for changes.

\* \*\*The Nodes\*\* (Kubelets) "watch" the API Server for new assignments.



\### 2. How the "Brain" Talks to the "Body" (Control Plane → Node)



When the Control Plane needs to get something done on a worker machine, it follows two main paths:



\* \*\*API Server to Kubelet:\*\* Used for fetching logs, attaching to running pods, and providing instructions.

\* \*\*API Server to Nodes/Pods/Services:\*\* This usually happens through the \*\*kube-proxy\*\*. It manages the "digital tunnels" (IPtables or IPVS) that allow traffic to flow to the right container.



\### 3. How the "Body" Talks to the "Brain" (Node → Control Plane)



The \*\*Kubelet\*\* is the most talkative component on the Node.



\* It periodically "calls home" to the API Server to report the status of the Node and its Pods.

\* If a container crashes, the Kubelet tells the API Server, "Hey, Pod #4 is down." The API Server then updates \*\*etcd\*\*, which triggers the Controller Manager to fix it.



---



\## 🛠️ The Three Main Communication Channels



| Path | Primary Method | Purpose |

| --- | --- | --- |

| \*\*User → Cluster\*\* | `kubectl` → API Server | You giving orders. |

| \*\*Internal Control\*\* | Components ↔ API Server | The "Brain" staying synced with the "Ledger." |

| \*\*Node → Node\*\* | Pod ↔ Pod (via CNI) | Your app talking to its own database on another machine. |



---



\## 🔒 The "Secret Sauce": Authentication



Every single communication mentioned above is secured.



\* They use \*\*TLS certificates\*\* (like a digital badge).

\* Even if a component wants to talk to the API Server, it must show its badge. If the badge isn't signed by the cluster's authority, the API Server hangs up the phone.



> \*\*Pro-Tip:\*\* If you ever see a "Connection Refused" error in K8s, it’s almost always because a component lost its "badge" (certificate) or doesn't have the "clearance" (RBAC) to talk to the API Server.



---



\### Why this matters



Because everything goes through the API Server, you have a single point of truth. If the API Server says a Pod is running, but the Node is actually on fire, the "Ledger" (etcd) will eventually reconcile that because of this constant back-and-forth chatter.



Would you like me to generate a visual representation of how a "service" routes a user's request from the internet down to a specific pod?



By the way, to unlock the full functionality of all Apps, enable \[Gemini Apps Activity](https://myactivity.google.com/product/gemini).

---

To visualize Kubernetes without getting lost in the technical jargon, think of it as a \*\*high-end automated shipping port.\*\* In this metaphor, your application is the \*\*cargo\*\*, and Kubernetes is the \*\*operating system of the port\*\* that ensures every box gets where it needs to go without human intervention.



---



\## 🏗️ The Kubernetes Port Imagery



\### 1. The Control Plane (The Management Office)



This is where the bosses sit. They don’t move the cargo themselves; they just make the decisions.



\* \*\*kube-apiserver (The Front Desk):\*\* The only way into the port. If you want to deploy an app, you talk to the clerk at the desk.

\* \*\*etcd (The Master Ledger):\*\* A secure safe containing the "truth." It records exactly how many boxes are supposed to be in the yard right now.

\* \*\*kube-scheduler (The Logistics Expert):\*\* Looks at the incoming cargo and decides which crane (Node) has enough space to handle it.

\* \*\*kube-controller-manager (The Quality Inspector):\*\* Constantly checks the yard. If a box falls over or a crane breaks, he notices and orders a replacement to match the Ledger.



\### 2. The Nodes (The Dock Workers)



These are the actual machines (servers) where the work happens.



\* \*\*kubelet (The On-Site Manager):\*\* A tiny manager living on every single crane. He takes orders from the Front Desk and makes sure the containers on his specific crane are running.

\* \*\*kube-proxy (The Switchboard):\*\* Handles the "phone lines" and "roads" so that cargo on Crane A can talk to cargo on Crane B.

\* \*\*Container Runtime (The Engine):\*\* The actual machinery that pulls the cargo out of the crate.



---



\## 🔄 The "Trick" to Visualizing the Flow



If you want to see how they work together in one mental "movie," follow a single command:



1\. \*\*The Request:\*\* You tell the \*\*API Server\*\*, "I want 3 copies of my app running."

2\. \*\*The Record:\*\* The API Server writes that wish into the \*\*etcd\*\* ledger.

3\. \*\*The Plan:\*\* The \*\*Controller Manager\*\* notices the ledger says "3" but the yard has "0." He screams for help.

4\. \*\*The Assignment:\*\* The \*\*Scheduler\*\* looks at all the \*\*Nodes\*\*, finds one with "room," and assigns the work.

5\. \*\*The Execution:\*\* The \*\*Kubelet\*\* on that Node sees the assignment, starts the \*\*Container\*\*, and reports back: "We're live!"



---



\## 💡 Quick Reference Table



| Component | Port Role | Real-World Function |

| --- | --- | --- |

| \*\*Pod\*\* | The Shipping Container | The smallest unit (your app) |

| \*\*Node\*\* | The Crane/Dock | The worker machine |

| \*\*Control Plane\*\* | The Tower | The brain of the cluster |

| \*\*Service\*\* | The Port Address | How the outside world finds your app |



Would you like me to dive deeper into how "Services" handle the networking part of this port metaphor?



By the way, to unlock the full functionality of all Apps, enable \[Gemini Apps Activity](https://myactivity.google.com/product/gemini).

