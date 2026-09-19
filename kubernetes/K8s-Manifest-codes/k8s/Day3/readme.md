## Hands On - 19 sept 26
When a Kubernetes PersistentVolumeClaim (PVC) is stuck in a Pending status, it means the control plane cannot find or dynamically provision a PersistentVolume (PV) that satisfies the claim's requirements.
```sh
kubectl describe pvc <your-pvc-name>
Events:
  Type     Reason          Age                   From                         Message
  ----     ------          ----                  ----                         -------
  Warning  VolumeMismatch  25s (x26 over 6m36s)  persistentvolume-controller  Cannot bind to requested volume "azure-disk-pv": storageClassName does not match
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
