## Hands On - 19 sept 26
When a Kubernetes PersistentVolumeClaim (PVC) is stuck in a Pending status, it means the control plane cannot find or dynamically provision a PersistentVolume (PV) that satisfies the claim's requirements.
```sh
kubectl describe pvc <your-pvc-name>
Events:
  Type     Reason          Age                   From                         Message
  ----     ------          ----                  ----                         -------
  Warning  VolumeMismatch  25s (x26 over 6m36s)  persistentvolume-controller  Cannot bind to requested volume "azure-disk-pv": storageClassName does not match
```
- AFTER FIXING:
```sh
k get pv,pvc
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/azure-disk-pv   90Gi       RWO            Retain           Bound    default/azure-disk-pvc   managed-csi    <unset>                          11s

NAME                                   STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/azure-disk-pvc   Bound    azure-disk-pv   90Gi       RWO            managed-csi    <unset>                 7s
```
**Why managed-csi is okay here**

This is a subtle but important distinction.

**Dynamic provisioning**
If you create only:
```yaml
kind: PersistentVolumeClaim
spec:
  storageClassName: managed-csi
```

then:
```
[PVC]
│
▼
[managed-csi]
│
▼
[Azure Disk CSI Driver]
│
▼
[NEW Azure Managed Disk]
```
The CSI driver provisions the Azure disk.

---

**Static provisioning**
With your current setup:
```
[Existing Azure Disk]
│
▼
[PV]
│
▼
[PVC]
│
▼
[Pod]
```
The `volumeHandle` identifies the existing disk:
`volumeHandle: "/subscriptions/.../disks/aks-disk"`

The CSI driver uses that ID when it needs to attach/mount the disk. Microsoft documents this static-PV approach specifically for existing Azure disks.

## POD Stuck in:

describe Pod says - 
```
Events:
  Type     Reason              Age                   From                     Message
  ----     ------              ----                  ----                     -------
  Normal   Scheduled           16m                   default-scheduler        Successfully assigned default/my-app-deployment-fb7766544-2c2sz to aks-userpool-30242799-vmss000000
  Warning  FailedAttachVolume  3m11s (x16 over 16m)  attachdetach-controller  AttachVolume.Attach failed for volume "azure-disk-pv" : rpc error: code = NotFound desc = Volume not found, failed with error: GET http://localhost:7788/subscriptions/99d8f8e9-1b37-4b2d-b102-416a5bc55c43/resourceGroups/k8ss/providers/Microsoft.Compute/disks/aks-disk
--------------------------------------------------------------------------------
RESPONSE 403: 403 Forbidden
ERROR CODE: AuthorizationFailed     ==========> GAVE AKS MANAGED IDENTITY CONTRIBUTOR on disk and 403 ** Gayab **
--------------------------------------------------------------------------------
{
  "error": {
    "code": "AuthorizationFailed",
    "message": "The client 'a97f70c2-1a54-4cce-9bde-490348cddedd' with object id '96a09038-814e-4fc1-b78c-1528145e39b8' does not have authorization to perform action 'Microsoft.Compute/disks/read' over scope '/subscriptions/99d8f8e9-1b37-4b2d-b102-416a5bc55c43/resourceGroups/k8ss/providers/Microsoft.Compute/disks/aks-disk' or the scope is invalid. If access was recently granted, please refresh your credentials."
  }
}
--------------------------------------------------------------------------------
  Warning  FailedAttachVolume  68s  attachdetach-controller  AttachVolume.Attach failed for volume "azure-disk-pv" : rpc error: code = Internal desc = Attach volume aks-disk to instance aks-userpool-30242799-vmss000000 failed with PUT http://localhost:7788/subscriptions/99d8f8e9-1b37-4b2d-b102-416a5bc55c43/resourceGroups/MC_k8ss_dummy_centralindia/providers/Microsoft.Compute/virtualMachineScaleSets/aks-userpool-30242799-vmss/virtualMachines/0
--------------------------------------------------------------------------------
RESPONSE 400: 400 Bad Request
ERROR CODE: BadRequest
--------------------------------------------------------------------------------
{
  "error": {
    "code": "BadRequest",
    "message": "Disk /subscriptions/99d8f8e9-1b37-4b2d-b102-416a5bc55c43/resourceGroups/k8ss/providers/Microsoft.Compute/disks/aks-disk cannot be attached to the VM because it is not in zone '3'."
  }
}               ========================> AKS is created in ONLY ZONE 3 
--------------------------------------------------------------------------------
```
### Others pods don't start coz PVC access mode is -  readwriteonce
```txt
 k get po -w
NAME                                 READY   STATUS              RESTARTS   AGE
my-app-deployment-74c45d45c8-5k4mp   1/1     Running             0          55s
my-app-deployment-74c45d45c8-cqd9v   0/1     ContainerCreating   0          55s
my-app-deployment-74c45d45c8-h6z5t   0/1     ContainerCreating   0          55s
```
> Pod describe
```txt
Events:
  Type     Reason              Age   From                     Message
  ----     ------              ----  ----                     -------
  Normal   Scheduled           28s   default-scheduler        Successfully assigned default/my-app-deployment-74c45d45c8-cqd9v to aks-userpool-30242799-vmss000000
  Warning  FailedAttachVolume  28s   attachdetach-controller  Multi-Attach error for volume "az-pv" Volume is already used by pod(s) my-app-deployment-74c45d45c8-r5k4d
```
