Yes — this is the important clue. With `storageClassName: managed-csi`, **you should not necessarily expect an Azure disk to appear immediately after creating the PVC**.

 The default `managed-csi` StorageClass in AKS is normally **dynamically provisioned when the PVC is actually used/bound**, depending on its `volumeBindingMode`.

 Let's check what happened in your cluster.

 ### 1\. Check the PVC

 Run:

```
kubectl get pvc my-pvc
```

 You want to see:

```
NAME      STATUS   VOLUME                                     CAPACITY
my-pvc    Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  90Gi
```

 If it says:

```
Pending
```

 then no Azure disk has been provisioned yet.

 ### 2\. Check the StorageClass

 Run:

```
kubectl get storageclass managed-csi -o yaml
```

 Pay particular attention to:

```
provisioner: disk.csi.azure.com
volumeBindingMode: WaitForFirstConsumer
```

 If you see:

```
volumeBindingMode: WaitForFirstConsumer
```

 then **this is likely exactly what you're seeing**.

 The PVC can remain `Pending` until you create a Pod that actually consumes it. This allows AKS to choose/provision the disk in the appropriate zone.

 ### 3. Create a test Pod

 For example:

```
apiVersion: v1
kind: Pod
metadata:
  name: pvc-test
spec:
  containers:
    - name: test
      image: busybox
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: my-pvc
```

 Apply it:

```
kubectl apply -f pod.yaml
```

 Then:

```
kubectl get pvc my-pvc
kubectl get pv
```

 You should eventually see something similar to:

```
NAME      STATUS   VOLUME                                     CAPACITY
my-pvc    Bound    pvc-12345678-....                          90Gi
```

 And:

```
kubectl exec -it pvc-test -- df -h /data
```

 should show approximately:

```
Filesystem      Size  Used Avail Use%
/dev/sdb         90G  ...   ...   ...
```

 There will be some filesystem overhead, so don't expect exactly `90.0G`.

 ### 4\. Check Azure

 Once the PVC is `Bound`, get the PV:

```
kubectl get pvc my-pvc -o wide
```

 Then:

```
kubectl get pv <PV-NAME> -o yaml
```

 You'll see something like:

```
spec:
  capacity:
    storage: 90Gi
  csi:
    driver: disk.csi.azure.com
    volumeHandle: /subscriptions/.../disks/...
```

 That `volumeHandle` points to the Azure managed disk that AKS dynamically created.

 So the expected flow is:

```
PVC
90Gi
 │
 ▼
StorageClass: managed-csi
 │
 ▼
Azure Disk CSI Driver
 │
 ▼
Azure Managed Disk
~90 GiB
 │
 ▼
PV
90Gi
 │
 ▼
Pod
 │
 ▼
df -h
~90 GiB
```

 **One important distinction from your previous `az-pv`:** your previous setup appears to be a **static PV pointing at an existing 1024-GiB disk**. That's why changing the PV metadata to `110Gi` didn't make `/dev/sdb` become 110 GiB.

 Your new `my-pvc` setup is **dynamic provisioning**, so it should create a new Azure disk based on the PVC request once provisioning is triggered.

 If you paste the output of:

```
kubectl get pvc my-pvc
kubectl get sc managed-csi -o yaml
```

 I can tell you exactly why the 90-GiB Azure disk isn't appearing yet.
