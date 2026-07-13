# DevSecOps & Kubernetes Notes

## DevSecOps

### Trivy
Trivy supports two targets for container images.
- Files inside container images
- Container image metadata
- Trivy scans the files inside container images for

Vulnerabilities
Misconfigurations: Trivy mainly supports Infrastructure as Code (IaC) files for misconfigurations.
Secrets
Licenses


### Namespace

* Namespace = Logical isolation inside a cluster (similar to a Resource Group concept).
* Used to separate applications, teams, or environments.
* Common examples:
  * dev
  * uat
  * prod

***

### Resource Quotas

* Restrict namespace resource consumption.
* Controls:
  * CPU
  * Memory
  * Storage
  * Number of Pods
  * Services

Example use case:

* Prevent one team from consuming all cluster resources.

***

## RBAC (Role-Based Access Control)

### Service Account (SA)

* Similar to a user account for applications.
* Pods authenticate to Kubernetes API using Service Accounts.
* Every Pod should have a Service Account.
* If none is specified, Kubernetes attaches the **default Service Account**.

### Roles

Define what actions are allowed.

Examples:

* Admin
* Developer
* ReadOnly

#### Role

* Namespace-scoped.
* Permissions only within a namespace.

#### ClusterRole

* Cluster-wide permissions.
* Can access cluster-level resources.

### Role Binding

Maps a Role to a Service Account.

```text
Service Account --> Role Binding --> Role --> Permissions
```

***

## Network Policies

By default, all Pods can communicate with each other.

Network Policies allow controlling Pod-to-Pod communication.

Commonly implemented using:

* Calico (CNI Plugin)

Control traffic using:

* Labels
* Namespace selectors
* Pod selectors

Example:

```text
Frontend Pod
    |
    | Allowed
    v
Backend Pod

Frontend Pod
    |
    | Denied
    X
Database Pod
```

***

## Kubernetes Policies

### Kyverno

Kyverno is an Admission Controller.

Used to enforce governance policies.

Examples:

* Do not allow `latest` image tag.
* Require resource limits.
* Prevent privileged containers.
* Enforce labels on all deployments.

Flow:

```text
Deployment Submitted
        |
        v
     Kyverno
        |
   Allow / Deny
        |
        v
 Kubernetes API
```

***

## Secret Management

### Option 1: Kubernetes Secrets

```text
Secret Resource
     |
     v
    Pod
```

### Option 2: Cloud Vault

Examples:

* Azure Key Vault
* HashiCorp Vault

### External Secrets Operator (ESO)

Retrieves secrets from external vaults and injects into Kubernetes.

```text
Azure Key Vault
       |
       v
External Secrets Operator
       |
       v
Kubernetes Secret
       |
       v
Pod
```

***

## Helm

Package Manager for Kubernetes.

Equivalent to:

```text
apt       -> Linux
npm       -> NodeJS
Helm      -> Kubernetes
```

Benefits:

* Template YAMLs
* Versioning
* Reusability
* Easy upgrades

Commands:

```bash
helm install myapp chart/
helm upgrade myapp chart/
helm uninstall myapp
```

***

# Application Security

Often overlooked in traditional delivery flow.

```text
Developer
    |
    v
QA
(Unit Tests + Regression Tests)
    |
    v
Production
```

Security scanners should be included.

***

## SAST (Static Application Security Testing)

Example:

* SonarQube

Features:

* Source code analysis
* Finds security vulnerabilities
* Finds code quality issues

Works without running the application.

```text
Source Code
    |
    v
 SonarQube
    |
    v
 Security Findings
```

***

## SCA (Software Composition Analysis)

Checks dependencies.

Both:

* Direct dependencies
* Indirect dependencies

Example:

```text
LangGraph
   |
   +---- Dependency A
   |
   +---- Dependency B
              |
              +---- Dependency C
```

Goal:

* Detect vulnerable libraries.
* Detect outdated packages.

***

## DAST (Dynamic Application Security Testing)

Does NOT require source code.

Needs:

* Running application
* URL

Example tools:

* OWASP ZAP
* Burp Suite

```text
Running Website
      |
      v
  DAST Tool
      |
      v
Security Findings
```

***

# Doubts / Topics To Learn

## Kubernetes Driver

Possible topics:

* CSI Drivers
* CNI Drivers
* Storage Drivers
* Device Drivers

Need clarification based on context.

***

## BuildKit

Modern Docker image builder.

Benefits:

* Faster builds
* Parallel execution
* Better caching
* Secrets during build

Example:

```bash
DOCKER_BUILDKIT=1 docker build .
```

***

## Terraform Meta Arguments

Terraform-specific arguments controlling resource lifecycle.

Common Meta Arguments:

### count

```hcl
resource "azurerm_resource_group" "test" {
  count = 3
}
```

### for\_each

```hcl
for_each = var.resource_groups
```

### depends\_on

```hcl
depends_on = [azurerm_resource_group.test]
```

### lifecycle

```hcl
lifecycle {
    prevent_destroy = true
}
```

### provider

```hcl
provider = azurerm.prod
```

***

## systemctl reload vs restart

### Reload

```bash
systemctl reload nginx
```

* Reads new configuration.
* Process remains running.
* No major interruption.

### Restart

```bash
systemctl restart nginx
```

* Stops service.
* Starts service again.
* Brief downtime possible.

***

## Authentication & Authorization in AKS

### Authentication (Who are you?)

Examples:

* Azure AD User
* Managed Identity
* Service Principal
* Service Account

### Authorization (What can you do?)

Examples:

* Kubernetes RBAC
* Azure RBAC for Kubernetes

Flow:

```text
User
  |
  v
Authentication
  |
  v
Authorization
  |
  v
Allowed / Denied
```

***

## Azure CNI Overlay / Pod IP from VNet Subnet

Reason Azure offers Pod IPs from subnet:

### Benefits

* Direct connectivity
* No NAT
* Easier firewall rules
* Easier route management

Flow:

```text
VNet
 |
 +-- Node Subnet
 |
 +-- Pod Subnet
```

***

## Enable Cilium Dataplane & Network Policy Engine

Cilium provides:

* Network Policies
* eBPF-based networking
* Better observability
* Better performance

Replaces many traditional iptables operations.

***

## Service Mesh

Examples:

* Istio
* Linkerd

Provides:

* mTLS
* Traffic Routing
* Retries
* Circuit Breaking
* Observability

```text
Pod A + Sidecar
      |
      |
Pod B + Sidecar
```

***

## CSI Driver for Key Vault

Azure Key Vault secrets mounted directly inside Pods.

```text
Key Vault
    |
    v
 CSI Driver
    |
    v
 Mounted Secret
    |
    v
    Pod
```

***

# Useful kubectl Commands

## Describe Pod

```bash
kubectl describe pod <pod-name>
```

Detailed information:

* Events
* Labels
* Conditions
* Volumes
* Image

***

## Edit Resource

```bash
kubectl edit pod <pod-name>
kubectl edit deployment <deployment-name>
```

***

## Execute Command in Pod

```bash
kubectl exec -it <pod-name> -- sh
```

or

```bash
kubectl exec -it <pod-name> -- bash
```

***

## Generate YAML

```bash
kubectl run nginx \
    --image=nginx \
    --dry-run=client \
    -o yaml > pod.yaml
```

***

## Show Labels

```bash
kubectl get pods --show-labels
```

Single pod:

```bash
kubectl get pod <name> --show-labels
```

***

## Wide Output

```bash
kubectl get pods -o wide
```

Provides:

* Pod IP
* Node
* Image
* Additional details

Less detailed than:

```bash
kubectl describe pod
```

***

## Scale Resources

```bash
kubectl scale deployment nginx --replicas=5
```

***

## Update Image

```bash
kubectl set image deployment/nginx nginx=nginx:1.28
```

***

## Rollout History

```bash
kubectl rollout history deployment/nginx
```

***

## Rollback

```bash
kubectl rollout undo deployment/nginx
```

Specific revision:

```bash
kubectl rollout undo deployment/nginx --to-revision=2
```

***

# Kubernetes Object Structure

```yaml
apiVersion:
kind:
metadata:
spec:
```

***

# Selectors & Labels

Selectors identify existing objects using labels.

```yaml
selector:
  matchLabels:
    app: nginx
```

Concept:

```text
Deployment
      |
      v
Selector
      |
      v
Matching Labels
      |
      v
Pods
```

***

# Discover API Information

Useful command:

```bash
kubectl explain pod
kubectl explain rs
kubectl explain rc
```

Examples:

```bash
kubectl explain deployment
kubectl explain deployment.spec
```

***

# Replication Controller vs ReplicaSet

## Replication Controller (Legacy)

* Older object
* Equality-based selectors only

Example:

```yaml
app=nginx
```

***

## ReplicaSet (Modern)

* Supports label selectors
* Used by Deployments

Example:

```yaml
matchLabels:
```

Flow:

```text
Deployment
      |
      v
ReplicaSet
      |
      v
Pods
```

***

# Services

## ClusterIP

Default service type.

Purpose:

* Permanent internal IP
* Internal access only

```text
Pod --> ClusterIP --> Pod
```

***

## NodePort

Port Range:

```text
30000 - 32767
```

Flow:

```text
User
  |
NodeIP:NodePort
  |
Service Port
  |
TargetPort
  |
Container
```

***

## ExternalName

Maps service to DNS.

```text
db-service
     |
     v
mysql.contoso.com
```

***

## LoadBalancer

Creates cloud load balancer.

```text
Internet
    |
Load Balancer
    |
Service
    |
Pods
```

***

# Internal Azure Load Balancer Service

```bash
kubectl expose deployment timer \
    --port=80 \
    --target-port=8080 \
    --type=LoadBalancer \
    --name=internal-service \
    --overrides='{
      "metadata": {
        "annotations": {
          "service.beta.kubernetes.io/azure-load-balancer-internal": "true"
        }
      }
    }'
```

***

# Debug Connectivity

```bash
kubectl run -it --rm debug-pod \
  --image=curlimages/curl \
  -- curl -v http://10.224.0.6
```

Useful for:

* DNS testing
* Service testing
* Pod communication testing

***

# AKS Built-In RBAC Roles

Reference:

<https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac?tabs=azure-cli#aks-built-in-roles>

Common roles:

* Azure Kubernetes Service RBAC Reader
* Azure Kubernetes Service RBAC Writer
* Azure Kubernetes Service RBAC Admin
* Azure Kubernetes Service Cluster Admin

***

# Contexts & Namespaces

View contexts:

```bash
kubectl config get-contexts
```

Example:

```text
CURRENT   NAME    CLUSTER   AUTHINFO                NAMESPACE
*         mk987   mk987     clusterUser_aks_mk987
```

Current namespace:

```bash
kubectl config view --minify --output 'jsonpath={..namespace}'
```

Change current namespace:

```bash
kubectl config set-context --current --namespace=dev
```

Verify:

```bash
kubectl config view --minify
```

***

# Important Interview Question

### Kubernetes Hierarchy

```text
Cluster
 |
 +-- Namespace
      |
      +-- Deployment
             |
             +-- ReplicaSet
                    |
                    +-- Pod
                           |
                           +-- Container
```

### AKS Ingress Flow

```text
User
 |
DNS
 |
Public IP
 |
Application Gateway / Load Balancer
 |
Ingress Controller
 |
Service
 |
Pod
 |
Container
 |
Application
```

### Security Layering

```text
Azure AD
    |
RBAC
    |
Namespace Isolation
    |
Network Policies
    |
Kyverno Policies
    |
Secrets Management
    |
Container Security
    |
Application Security (SAST/SCA/DAST)
```
