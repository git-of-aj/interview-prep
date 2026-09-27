### Helm

```
Chart   = Blueprint / Package
Release = Installed instance
Values  = Configuration
Helm    = Kubernetes package manager
```

 ### Helm search

```
helm search hub
        ↓
Artifact Hub

helm search repo
        ↓
Locally configured Helm repositories
```

 ## Helm Model

```
              Chart
                +
          values.yaml
                +
             --set
                ↓
              Helm
                ↓
      Kubernetes manifests
                ↓
       Kubernetes API Server
                ↓
      ┌─────────┼─────────┐
      ↓         ↓         ↓
 Deployment   Service   ConfigMap
      ↓
    Pods
```

 # 14\. Helm

 ## What is Helm?

 **Helm is a package manager for Kubernetes.**

 It allows you to package Kubernetes resources into reusable **Charts** and install those Charts as **Releases**.

 The basic relationship is:

```
Helm
  ↓
Chart + Values
  ↓
Kubernetes manifests
  ↓
Kubernetes API Server
  ↓
Kubernetes resources
```

---

 # 15\. Helm with AKS

 When using Helm with **Azure Kubernetes Service (AKS)**, Helm does not need to be installed inside the Kubernetes cluster.

 Since Helm v3, Helm is primarily a **client-side CLI**.

 You can install the Helm CLI:

 - On your local machine
- In Azure Cloud Shell
- In a CI/CD environment

 Your Helm client communicates with the Kubernetes API server.

 Conceptually:

```
Your machine
     │
     │ Helm CLI
     ↓
Kubeconfig
     ↓
AKS API Server
     ↓
Kubernetes resources
```

---

 # 16\. Helm Uses kubeconfig

 Helm uses your Kubernetes client configuration (`kubeconfig`).

 By default, Helm uses the **current Kubernetes context**.

 Check the current context:

```
kubectl config current-context
```

 List available contexts:

```
kubectl config get-contexts
```

 Switch context:

```
kubectl config use-context <context-name>
```

 Therefore, before running Helm commands against AKS, make sure your local Kubernetes authentication/context is configured correctly.

 For example:

```
az aks get-credentials \
  --resource-group <resource-group> \
  --name <aks-cluster>
```

 Then verify:

```
kubectl get nodes
```

---

 # 17\. Helm Architecture

 A useful mental model is:

```
                 Helm Chart
                     +
                 values.yaml
                     +
                 --set options
                     ↓
                   Helm
                     ↓
            Kubernetes manifests
                     ↓
            Kubernetes API Server
                     ↓
        ┌────────────┬─────────────┐
        ↓            ↓             ↓
   Deployment     Service      ConfigMap
        ↓
       Pods
```

---

 # 18\. Helm Terminology

 | Term | Meaning |
| --- | --- |
| **Helm** | Kubernetes package manager |
| **Chart** | Package / blueprint containing Kubernetes resources |
| **Repository** | Location where Charts are shared |
| **Values** | Configuration supplied to a Chart |
| **Release** | Installed instance of a Chart |
| **Helm Client** | The `helm` CLI |
| **Helm Library** | Helm's underlying engine/library used to perform Helm operations |

### Simple mental model

```
Chart
  =
Blueprint / Package

Release
  =
Installed instance of that Chart
```

 For example:

```
Chart:
  nginx

Release:
  my-nginx
```

 The same Chart can therefore be installed multiple times as different Releases.

---

 # 19\. Helm Chart Sources

 Helm Charts can come from different sources, including:

 - Helm repositories
- OCI-compliant registries
- Cloud container registries
- Public Chart repositories
- Artifact Hub

---

 # 20\. Artifact Hub

 Artifact Hub is a catalog for finding Kubernetes-related packages, including Helm Charts.

 Search:

 https://artifacthub.io/packages/search?kind=0

 For example, searching for:

```
helm search hub argo-cd
```

 can return an Artifact Hub result for the Argo CD Helm Chart.

 Conceptually:

```
helm search hub
       ↓
Artifact Hub
       ↓
Charts from many publishers/repositories
```

---

 # 21\. `helm search hub` vs `helm search repo`

 These commands search different things.

 ## `helm search hub`

```
helm search hub argo-cd
```

 Searches **Artifact Hub**.

```
helm
 ↓
Artifact Hub
 ↓
Charts from many repositories
```

 It can therefore discover Charts that you have **not added as local Helm repositories**.

---

 ## `helm search repo`

```
helm search repo argo
```

 Searches the Helm repositories that you have already added locally.

 For example:

```
helm repo add <repo-name> <repo-url>
```

 Then:

```
helm repo update
```

 And:

```
helm search repo <repo-name>
```

 Conceptually:

```
helm repo add
      ↓
Local Helm repository configuration
      ↓
helm search repo
      ↓
Search locally configured repositories
```

 ### Key difference

 | Command | Searches |
| --- | --- |
| `helm search hub` | Artifact Hub |
| `helm search repo` | Repositories configured in your local Helm client |

---

 # 22\. Helm Cheat Sheet

```
┌──────────────────────────────────────────────────────────┐
│                    HELM CHEAT SHEET                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  1. Helm         = Kubernetes package manager             │
│                                                          │
│  2. Chart        = Package / blueprint                    │
│                                                          │
│  3. Repository   = Place where Charts are shared          │
│                                                          │
│  4. Values       = Configuration supplied to a Chart      │
│                                                          │
│  5. Release      = Installed instance of a Chart           │
│                                                          │
│  6. Helm Client  = `helm` CLI                              │
│                                                          │
│  7. Helm Library = Engine performing Helm operations       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

