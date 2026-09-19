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

### PVC
- PersistentVolumeClaim (PVC) is a request for storage by a user.
- Just like Pods consume node resources and PVCs consume PV resources.
- PersistentVolumes can be configured to be expandable. This allows you to resize the volume by editing the corresponding PVC object, requesting a new larger amount of storage.
-  underlying StorageClass has the field allowVolumeExpansion set to true.
> Note: You can only use the volume expansion feature to grow a Volume, not to shrink it.
- Claims can request specific size and access modes (e.g., they can be mounted ReadWriteOnce, ReadOnlyMany, ReadWriteMany, or ReadWriteOncePod, see [AccessModes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).
