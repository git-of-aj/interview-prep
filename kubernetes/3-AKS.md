## StorageClass
- A StorageClass provides a way for administrators to describe the classes (variety or types) of storage they offer.
- cluster admin should create and expose variety of storageClassName.
- You can mark a StorageClass as the default for your cluster
- When a PVC does not specify a storageClassName, the default StorageClass is used.
> You should try to only have one StorageClass in your cluster that is marked as the default. [Most recent one is used] The reason that Kubernetes allows you to have multiple default StorageClasses is to allow for seamless migration.
- Each StorageClass has a **provisioner** that determines what volume plugin (Azure files, local or NFS etc) is used for provisioning PVs. This field must be specified.

## PersistentVolume 
- abstracts details of how storage is provided from how it is consumed.
- PersistentVolume =  piece of storage in the cluster.  provisioned by an administrator or dynamically provisioned using Storage Classes.
- This API object captures the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.
- Types of Persistent volumes - CSI, Azure Disk, File share, EBS, EFS, anyother NFS, ISCI - [K8s Docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes)

### PVC
- PersistentVolumeClaim (PVC) is a request for storage by a user.
- Just like Pods consume node resources and PVCs consume PV resources.
- PersistentVolumes can be configured to be expandable. This allows you to resize the volume by editing the corresponding PVC object, requesting a new larger amount of storage.
-  underlying StorageClass has the field allowVolumeExpansion set to true.
> Note: You can only use the volume expansion feature to grow a Volume, not to shrink it.
- Claims can request specific size and access modes (e.g., they can be mounted ReadWriteOnce, ReadOnlyMany, ReadWriteMany, or ReadWriteOncePod, see [AccessModes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).

-----------
> 💡 Migrating to CSI drivers from in-tree (means the code logic to connects resides in main k8s code, so volume provider can only do bugFix when k8s releases a patch) plugins
# ChatGPT:
Sure. The easiest way to understand this is to first separate **persistent storage** from **ephemeral storage**.

 A **CSI driver** is the component that knows how to talk to a storage system. Kubernetes gives you three ways to use that CSI driver from a Pod.

 ## 1\. Through a PersistentVolumeClaim — persistent storage

 This is the most common approach.

 The flow is:

```
Pod
 │
 │ uses
 ▼
PVC
 │
 │ binds to
 ▼
PV
 │
 │ managed by
 ▼
CSI Driver
 │
 ▼
Actual storage
(EBS / Azure Disk / EFS / etc.)
```

 For example:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 10Gi
```

 Then your Pod references the PVC:

```
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /data
          name: data

  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: my-data
```

 The important part is:

```
persistentVolumeClaim:
  claimName: my-data
```

 The Pod doesn't directly deal with EBS.

 It says:

 > "Give me the storage represented by this PVC."

 Kubernetes/CSI handles the rest.

 ### What happens if the Pod dies?

 The storage **can remain**.

 That's why it's called **persistent**.

 For example:

```
Pod
 │
 ▼
PVC ────> PV ────> EBS volume
                     │
                     │ remains
                     ▼
                  10 GiB
```

 A new Pod can mount the same PVC.

 This is what you'd typically use for things like:

 - databases
- application data
- user uploads
- persistent files

---

 # 2\. Generic ephemeral volume

 Now let's say you don't actually want the storage to survive the Pod.

 You want:

 > "When this Pod starts, give it a fresh volume. When this Pod is deleted, delete that volume."

 That's where a **generic ephemeral volume** comes in.

 Interestingly, it still uses a **StorageClass and CSI driver**.

 Example:

```
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /scratch
          name: scratch

  volumes:
    - name: scratch
      ephemeral:
        volumeClaimTemplate:
          spec:
            storageClassName: ebs-sc
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 10Gi
```

 Notice something interesting:

 There is **no PVC that you manually created**.

 You put a PVC template inside the Pod:

```
ephemeral:
  volumeClaimTemplate:
```

 Kubernetes effectively does this for you:

```
Pod created
   │
   ▼
Kubernetes creates PVC
   │
   ▼
CSI driver creates volume
   │
   ▼
Pod uses volume
```

 When the Pod is deleted:

```
Pod deleted
   │
   ▼
ephemeral PVC deleted
   │
   ▼
CSI volume deleted
```

 So:

```
Generic ephemeral volume
=
"Create a temporary PVC for this Pod."
```

 This is useful for things like temporary scratch space where you want **real CSI-backed storage**, but don't need the data after the Pod disappears.

---

 # 3\. CSI ephemeral volume

 This one is slightly different.

 Here you tell Kubernetes:

 > "Use this CSI driver to provide a temporary volume directly to this Pod."

 Example:

```
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: /data
          name: my-volume

  volumes:
    - name: my-volume
      csi:
        driver: example.csi.k8s.io
        volumeAttributes:
          foo: bar
```

 Notice that there is:

 - no PVC
- no PV
- no StorageClass

 Instead:

```
Pod
 │
 │ directly asks
 ▼
CSI driver
 │
 ▼
temporary storage
```

 But there's an important catch:

 > **The CSI driver itself must support ephemeral volumes.**

 That's what the Kubernetes documentation means by:

 > "with a CSI ephemeral volume if the driver supports that"

 Not every CSI driver supports this mode.

---

 # So what's the difference?

 Here's the easiest comparison:

 |  | PVC | Generic ephemeral | CSI ephemeral |
| --- | --- | --- | --- |
| Persistent? | ✅ Yes | ❌ No | ❌ No |
| PVC involved? | ✅ Yes | ✅ Automatically created | ❌ No |
| PV involved? | ✅ Yes | Usually yes, dynamically provisioned | ❌ No |
| StorageClass? | Usually | Usually | ❌ |
| CSI driver? | ✅ | ✅ | ✅ |
| Driver must specifically support ephemeral? | No | No | **Yes** |
| Survives Pod deletion? | Usually ✅ | ❌ | ❌ |

Think of them like this:

 ### PVC

 > **"I need storage that belongs to my application."**

```
Pod → PVC → PV → CSI → Storage
                         ↑
                    stays around
```

 ### Generic ephemeral

 > **"I need a temporary storage volume, but provision it using the normal PVC/StorageClass machinery."**

```
Pod
 │
 └── ephemeral volume
       │
       ▼
   temporary PVC
       │
       ▼
      PV
       │
       ▼
      CSI
       │
       ▼
    Storage

Pod deleted → everything gets cleaned up
```

 ### CSI ephemeral

 > **"I want this CSI driver to provide a temporary volume directly for my Pod."**

```
Pod → CSI driver → temporary volume

Pod deleted → volume disappears
```

---

 ## Why are there two kinds of ephemeral volumes?

 This is the part that often confuses people.

 **Generic ephemeral volumes** use Kubernetes' normal dynamic provisioning mechanism:

```
Pod
 ↓
PVC
 ↓
StorageClass
 ↓
CSI driver
```

 Therefore, they work with CSI drivers that support **normal dynamic provisioning**.

 **CSI ephemeral volumes** bypass the PVC/PV provisioning mechanism:

```
Pod
 ↓
CSI driver
```

 This gives the CSI driver more direct control, but therefore the **CSI driver must explicitly implement support for ephemeral volumes**.

---

 ## A practical example

 Imagine you're running a web application.

 ### Case 1 — User uploads

 You need the files tomorrow even if the Pod restarts.

 Use:

```
PVC → PV → CSI → EBS/EFS/Azure Disk/etc.
```

 ### Case 2 — Temporary processing

 Your application needs 20 GB of scratch space while processing a video.

 You don't care about the data after the Pod finishes.

 Generic ephemeral volume can be appropriate:

```
Pod
 ↓
Generic ephemeral
 ↓
temporary PVC/PV
 ↓
CSI storage
```

 ### Case 3 — CSI driver provides special temporary storage

 Suppose a CSI driver specifically implements an ephemeral volume mechanism for some specialized storage functionality.

 Then you can use:

```
Pod
 ↓
CSI ephemeral volume
 ↓
CSI driver
```

## DEMO - Attach Azure Disk AKS
- By default AKS has Azure Disk CSI Driver
```sh
kubectl get pods -n kube-system | grep -i disk
csi-azuredisk-node-gbfd2                               3/3     Running   0              4h9m
csi-azuredisk-node-p9ttm                               3/3     Running   0              4h9m
ananay [ ~ ]$ kubectl get csidriver
NAME                 ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS                REQUIRESREPUBLISH   MODES                  AGE
disk.csi.azure.com   true             false            false             <unset>                      false               Persistent             4h11m
file.csi.azure.com   false            true             false             api://AzureADTokenExchange   true                Persistent,Ephemeral   4h11m
```


Yes — that is expected for **AKS**.

 Even if you selected **no optional add-ons**, Azure Disk CSI can still be present because it is a **built-in AKS infrastructure component**, not an optional addon in the usual sense.

 Your output:

```
csi-azuredisk-node-gbfd2   3/3 Running
csi-azuredisk-node-p9ttm   3/3 Running
```

 means the **Azure Disk CSI node plugin is already running on your AKS nodes**.

 ### What you're seeing

 AKS deploys the Azure Disk CSI driver components into `kube-system`, including the node DaemonSet:

```
kubectl get daemonset -n kube-system | grep azuredisk
```

 You'll likely see:

```
csi-azuredisk-node    2    2    2    2    2
```

 The `csi-azuredisk-node` pods run on each node because the driver needs to perform operations such as:

```
Azure Managed Disk
       |
       | attach
       v
    AKS Node
       |
       | mount
       v
     Pod
```

 There is also a controller component responsible for provisioning/attaching volumes. Check:

```
kubectl get pods -n kube-system | grep -i azuredisk
```

 You should see both **node** and **controller** components.

 ### Check the CSI driver registration

 Run:

```
kubectl get csidriver
```

 You should see:

```
disk.csi.azure.com
file.csi.azure.com
```

 The important one for our demo is:

```
disk.csi.azure.com
```

 You can inspect it:

```
kubectl describe csidriver disk.csi.azure.com
```

 ### And check your existing StorageClasses

 Before creating our own:

```
kubectl get storageclass
```

 On a typical AKS cluster you'll often find something like:

```
NAME                      PROVISIONER          RECLAIMPOLICY
managed-csi               disk.csi.azure.com   Delete
managed-csi-premium       disk.csi.azure.com   Delete
```

 If `managed-csi` is already there, **you don't actually need to create another StorageClass for the demo**.

 You can simply use:

```
spec:
  storageClassName: managed-csi
```

 So your simplest demo can be:

```
AKS
 │
 ├── Azure Disk CSI driver (already installed by AKS)
 │
 ├── StorageClass: managed-csi (likely already present)
 │
 ├── PVC: 10Gi
 │
 └── Deployment
       │
       └── /data
              │
              └── Azure Managed Disk
```

 The interesting thing to understand next is **who actually creates the Azure disk and how it gets attached to the VM/node**. That's where CSI becomes much clearer.

 The key takeaway is:

 > **CSI is the storage interface/driver mechanism. PVC, generic ephemeral, and CSI ephemeral are three different ways a Pod can consume storage through that mechanism.**

 And **"ephemeral" means the storage is tied to the Pod's lifetime, not that CSI itself is ephemeral.**
