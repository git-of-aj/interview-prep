

 # 9\. `kubectl apply` Best Practices

 It is generally useful to keep resources related to the same microservice or application tier organized together.

 A common structure is:

```
my-application/
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── secret.yaml
└── ingress.yaml
```

 For larger applications, you can organize by component:

```
k8s/
├── frontend/
│   ├── deployment.yaml
│   └── service.yaml
│
├── backend/
│   ├── deployment.yaml
│   └── service.yaml
│
└── database/
    ├── deployment.yaml
    └── service.yaml
```

---

 ## Applying a Manifest

```
kubectl apply -f deployment.yaml
```

 Multiple files:

```
kubectl apply -f file1.yml -f file2.yml
```

 You can also apply a manifest directly from a URL:

```
kubectl apply -f https://k8s.io/examples/application/nginx/nginx-deployment.yaml
```

---

 ## Applying a Directory

 For multiple manifests in a directory:

```
kubectl apply -f ./k8s/
```

 This is often convenient for managing an application's Kubernetes resources together.

---

 # 10\. Resource Ordering

 When multiple resources are defined in a manifest, Kubernetes processes them based on the submitted resource definitions.

 However, **do not rely on resource ordering as a general mechanism for making an application work**.

 Kubernetes controllers are asynchronous, so a resource being created first does not necessarily mean it is fully ready before the next resource starts.

 For example:

```
Service created
      ↓
Deployment created
      ↓
Pod scheduled
      ↓
Container starts
      ↓
Readiness probe passes
      ↓
Service sends traffic
```

 The important dependency is that the application becomes **Ready**, not merely that the resource exists.

---

 # 11\. Selecting Resources with Labels

 For larger numbers of resources, labels make it easier to target specific resources.

 Example:

```
labels:
  app: nginx
```

 You can then use:

```
kubectl delete deployment,services -l app=nginx
```

 The selector:

```
-l app=nginx
```

 means:

 > Select resources whose `app` label is `nginx`.

 You can also use:

```
kubectl get pods -l app=nginx
```

 or:

```
kubectl get all -l app=nginx
```

---

 # 12\. Editing a Deployment

 You can edit a Deployment directly:

```
kubectl edit deployment/my-nginx
```

 This opens the live Kubernetes resource in your configured editor.

 For production environments, it is generally preferable to make changes in the source manifest/Helm configuration and apply them rather than relying on manual edits.

---

 # 13\. Labels for Stable and Canary Releases

 Labels can be used to distinguish different versions of an application.

 ### Stable version

```
name: frontend
replicas: 3

labels:
  app: guestbook
  tier: frontend
  track: stable

image: gb-frontend:v3
```

 ### Canary version

```
name: frontend-canary
replicas: 1

labels:
  app: guestbook
  tier: frontend
  track: canary

image: gb-frontend:v4
```

 The important idea is that both releases share:

```
app: guestbook
tier: frontend
```

 but have different:

```
track: stable
```

 and:

```
track: canary
```

---

 ## Service Selector

 The Service can select both versions by **not including `track`**:

```
selector:
  app: guestbook
  tier: frontend
```

 Therefore:

```
                 Service
                    │
          ┌─────────┴─────────┐
          ↓                   ↓
     Stable Pods          Canary Pods
     track=stable         track=canary
          │                   │
          └───────┬───────────┘
                  ↓
             Service traffic
```

 If there are:

```
Stable  = 3 replicas
Canary  = 1 replica
```

 then there are 4 selected Pods in total.

 With ordinary Kubernetes Service load balancing, this can result in traffic being distributed across the selected endpoints, but **the replica ratio should not be treated as a precise traffic-percentage guarantee**.

---



---

 # 23\. Quick Mental Models

 ## Kubernetes Probe Model

```
Startup
   │
   ↓
"Have you finished starting?"
   │
   ↓
Readiness
   │
   ↓
"Can I send traffic to you?"
   │
   ↓
Service sends traffic
   │
   ├───────────────┐
   ↓               ↓
Readiness        Liveness
   │               │
"Still ready?"   "Still alive?"
   │               │
   ↓               ↓
Traffic          Restart if needed
```

---

 ## Readiness Failure Model

```
Application
     │
     │ listening on :8080?
     ↓
   ❌ NO
     │
     ↓
connection refused
     │
     ↓
Readiness probe fails
     │
     ↓
Pod becomes NotReady
     │
     ↓
Service stops sending
traffic to that Pod
```

---


---

 # 24\. Most Important Takeaways

 ### Readiness probe

```
Readiness = "Should this Pod receive traffic?"
```

 ### Liveness probe

```
Liveness = "Is this container still alive?"
```

 ### Startup probe

```
Startup = "Has this application finished starting?"
```

 ### `connection refused`

```
connection refused
        ↓
TCP connection could not be established
        ↓
Usually means nothing is listening on that IP:port
```

 For this incident:

```
10.201.4.223:8080
       ↓
❌ Connection refused
       ↓
Readiness probe failed
```

 ### PreStop

```
PreStopHook failed
        ↓
Shutdown/pre-stop action did not complete successfully
```

 It does **not automatically mean** the PreStop hook caused the original application problem.

 
