### Config Map
>  decouple environment-specific configuration from your container images, so that your applications are easily portable.
- A ConfigMap is an API object used to store non-confidential data in key-value pairs.
- You can write a Pod spec that refers to a ConfigMap and configures the container(s) in that Pod based on the data in the ConfigMap.
- The Pod and the ConfigMap must be in the same namespace.
- Mounted ConfigMaps are updated automatically. the total delay from the moment when the ConfigMap is updated to the moment when new keys are projected to the Pod can be as long as the kubelet sync period + cache propagation delay, where the cache propagation delay depends on the chosen cache type (it equals to watch propagation delay, ttl of cache, or zero correspondingly).

| Situation                        | Best choice            | Example                                                                                                                                                        |
| -------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Simple key-value configuration   | Environment variables  | `LOG_LEVEL=INFO`, `APP_ENV=prod`                                                                                                                               |
| Application uses CLI flags       | Command-line arguments | `--port=8080`, `--debug=false`                                                                                                                                 |
| Application expects config files | Volume mount           | `nginx.conf`, `application.yml`, `prometheus.yml`, `haproxy.cfg`                                                                                               |
| Large structured configuration   | Volume mount           | YAML, JSON, XML, INI files                                                                                                                                     |
| Configuration changes frequently | Volume mount           | Mounted ConfigMaps can be updated on disk without recreating the ConfigMap itself, though whether the application picks up changes depends on the application. |
### Pratically checked.... updated configmap (which was mounted as env) and pods don not show new value. | Restart Pods via Rollout
4 ways to declare config:
1. Inside a container command and args
2. Environment variables for a container
3. Add a file in read-only volume, for the application to read
4. Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap
- for first 3 kubelet uses the data from the ConfigMap when it launches container(s) for a Pod.
note:
A ConfigMap is not designed to hold large chunks of data. The data stored in a ConfigMap cannot exceed 1 MiB. If you need to store settings that are larger than this limit, you may want to consider mounting a volume or use a separate database or file service.

#### ConfigMap as volume:
```
etcd
  │
  ▼
API Server
  │
  ▼
kubelet on Worker-2
  │
  ▼
creates local volume
  │
  ▼
mounts it into container
```

```yml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: api-deployment
  labels:
    app: api
    Deployed: "true"
    creator: AJ
    env: dev

spec:
  replicas: 5

  selector:
    matchLabels:
      app: api
      env: dev

  template:
    metadata:
      labels:
        app: api
        env: dev

    spec:
      containers:
        - name: api
          image: acr8r.azurecr.io/api:v1.1
          ports:
            - containerPort: 8000
          # envFrom:
          #   - configMapRef:
          #       name: simple-configmap
          volumeMounts:
            - name: env-vars
              mountPath: "/etc/simple01"
              readOnly: true
      volumes:
        - name: env-vars
          configMap:
            name: simple-configmap
```
* **`/etc/foo` is created by the kubelet on the node where the Pod is running.** It fetches the ConfigMap from the Kubernetes API server and mounts it into the container at `/etc/foo`.

* **The ConfigMap is the persistent source of truth.** It is stored in the cluster (in etcd via the API server), not on any specific worker node.

* **The mounted `/etc/foo` directory is ephemeral.** It exists only for the lifetime of the Pod and is removed when the Pod is deleted.

* **If the Pod is rescheduled to another node,** the kubelet on the new node fetches the same ConfigMap and recreates the `/etc/foo` mount automatically.

* **ConfigMap volumes are for configuration, not data persistence.** If you need data to survive Pod deletion or restarts, use a **PersistentVolume (PV)** and **PersistentVolumeClaim (PVC)** instead.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: simple-configmap
data:
  APP_ENV: dev
  DB_HOST: mysql
  DB_PORT: "3306"

Inside your pod:

/etc/simple01/
├── APP_ENV
├── DB_HOST
└── DB_PORT

You will not get:

echo $APP_ENV

because you did not inject environment variables.
```
#### Rollout
command triggers a graceful, zero-downtime rolling restart of your pods. Under the hood, it injects a timestamp annotation into the pod template, forcing Kubernetes to sequentially spin up new pods and terminate old ones according to your deployment's update strategy.
 Valid resource types include:

  *  deployments
  *  daemonsets
  *  statefulsets

```sh
# check if value updated here
 kubectl get configmap name: simple-configmap -o yaml

 kubectl rollout undo/restart/status deployment/abc
  # Restart deployments with the 'app=nginx' label
  kubectl rollout restart deployment --selector=app=nginx
```

### Secrets
- Using a Secret means that you don't need to include confidential data in your application code.
- Secrets can be mounted as data volumes or exposed as environment variables to be used by a container in a Pod.
- Secret needs to be created before any Pods that depend on it
- behaves same like configmaps... rollout after updates // when mounted as drive, each secret is a file.
> Caution: Kubernetes Secrets are, by default, stored unencrypted in the API server's underlying data store (etcd). Anyone with API access can retrieve or modify a Secret, and so can anyone with access to etcd.
- You can use Secrets for purposes such as the following:
1. Set environment variables for a container.
2. Provide credentials such as SSH keys or passwords to Pods.
3. Allow the kubelet to pull container images from private registries.

### Service Account
- A `default` SA is created in every NameSpace.
> Kubernetes does not separate Users vs SA because RBAC needs two concepts; it separates them because identity creation, credential management, and lifecycle are fundamentally different for people and software.
| Concern                   | Human User | ServiceAccount |
| ------------------------- | ---------- | -------------- |
| Created by Kubernetes     | No         | Yes            |
| Namespace scoped          | No         | Yes            |
| Used by Pods              | No         | Yes            |
| Managed by external IdP   | Usually    | No             |
| Automatic token lifecycle | External   | Kubernetes     |
| Interactive login         | Yes        | No             |

##### ServiceAccount token volume projection: Assign a temp JWT token to pod
- Microsoft Entra Workload ID uses Service Account Token Volume Projection to enable pods to use a Kubernetes identity.
- Workload ID covers the pod-to-Azure identity scenario in AKS - how applications running in pods authenticate to Microsoft Entra-protected services
- On AKS automatic, this opetion is pre-configured.
> The projected ServiceAccount token is not an Azure access token. It's a Kubernetes-issued identity document that proves "this pod is running as ServiceAccount X in namespace Y." Azure Workload Identity uses that proof to obtain a real Azure access token from Microsoft Entra ID. That's why ServiceAccount token projection is the foundation that makes secretless authentication from AKS to Azure resources possible.
```
Deployment
      │
      ▼
Uses ServiceAccount "storage-reader"
      │
      ▼
Kubernetes generates a temporary ServiceAccount token
      │
      ▼
The token is projected (placed) into the pod as a file
      │
      ▼
Azure Identity SDK reads the token
      │
      ▼
The SDK sends it to Microsoft Entra ID
      │
      ▼
Entra ID checks:
"Is this ServiceAccount trusted?"
      │
      ▼
If yes, it issues an Azure access token
      │
      ▼
The pod uses that Azure token to access Azure Storage, Key Vault, or other resources based on the managed identity's RBAC permissions.
```
![](https://learn.microsoft.com/en-us/azure/aks/media/workload-identity-overview/workload-id-model.png)
