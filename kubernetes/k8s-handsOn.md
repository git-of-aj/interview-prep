# Commands and Flags
- Login
```sh
az aks get-credentials --resource-group <resource_group_name> --name <cluster_name>
context saved in $HOME\.kube\config
```
- A Kubernetes context is like a saved connection profile. It tells kubectl three things:
> Which cluster? Which user? Which namespace?
```sh
 kubectl config get-contexts
CURRENT   NAME           CLUSTER        AUTHINFO                          NAMESPACE
          aks-v1         aks-v1         clusterUser_aks-demo_aks-v1
          az1001demo     az1001demo     clusterUser_az-1001_az1001demo
          myAKSCluster   myAKSCluster   clusterUser_aks-rg_myAKSCluster
*         test           test           clusterUser_DevOps_test
 anana  kubectl config use-context aks-v1
Switched to context "aks-v1".
```
- `The -A` (or --all-namespaces) | Namespace is cluster scoped object hence `k get ns -A` no benefit.. 
```sh
kubectl get pods -A
# Shows Pods in all namespaces.

#Resources in namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false
```

## alias
Powershell:
```pwsh
set-Alias -Name k -Value "kubectl"
notepad $PROFILE
# add above line in bottom and u good !!
```
Linux:
```sh
nano ~/.bashrc
alias shortName='your long command here'
```
## Version
Your client is 2 minor versions newer than the server, which is outside Kubernetes' recommended supported version skew, so matching or closer versions are recommended for the best compatibility.
Command:
```sh
1. kubectl version
Client Version: v1.36.0 -- My laptop
Kustomize Version: v5.8.1
Server Version: v1.34.7 -- AKS 

# means:
                Your Computer
         +------------------------+
         | kubectl v1.36.0        |
         | Kustomize v5.8.1       |
         +-----------+------------+
                     |
                     | HTTPS REST API
                     |
                     ▼
      Kubernetes API Server v1.34.7
                     |
          +----------+-----------+
          |                      |
      Worker Node           Worker Node
          |                      |
        Pods                   Pods

## Nodes version:
k get no
NAME                                STATUS   ROLES    AGE   VERSION
aks-agentpool-25438723-vmss000000   Ready    <none>   28m   v1.34.7
aks-agentpool-25438723-vmss000001   Ready    <none>   28m   v1.34.7
```
## Service Accounts
- 
- Namespaced: Each service account is bound to a Kubernetes namespace. Every namespace gets a default ServiceAccount upon creation.
> USER ACCOUNT / SERVICE ACCOUNT = WHO AM I? || RBAC ROLE = WHAT CAN I DO? || ROLE BINDING = CONNECTS THE TWO
- Kubernetes itself does not create OR store user accounts. It trusts an external authentication mechanism (such as client certificates (certs via kubeadm for self managed cluster), cloud IAM, or an identity provider) to establish that someone is david. Once that identity is established, Kubernetes RBAC determines what david can do.
- local human identity: X.509 Client Certificates (signed by the cluster's CA) and Service Accounts (which act as local accounts for humans or processes)
![](https://learn.microsoft.com/en-us/azure/aks/media/concepts-identity/aad-integration.png)

- AKS By default has local accounts, `MS recommends to disable it` but noema didn't disabled it in PROD.
- Once disabled `az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin` gives error: `Operation failed with status: 'Bad Request'. Details: Getting static credential isn't allowed because this cluster is set to disable local accounts.`
- But by default: Authentication and Authorization: Local accounts with Kubernetes RBAC && Local accounts: Enabled, in this :
- `Azure Kubernetes Service RBAC Reader`: Doesn't works if you not using Azure RBAC but `Azure Kubernetes Service Cluster User Role`: `WORKS` ...

```sh
k auth whoami
k auth can-i create deployment --as tiffany@ananayojha.rocks
kubectl get clusterrolebindings
kubectl get rolebindings -n nginx-app
```
-------------------
### Reason why MS asks to `Disable` Local accounts ....... Once u run az aks get-credentials ..... U get super user access. 

```json
az aks show \
  --resource-group DevOps \
  --name test \
  --query "{aadProfile:aadProfile,local:disableLocalAccounts}" \
  -o json

{
  "aadProfile": null,
  "local": false
}
```

This means:

* **`aadProfile: null`** → **Microsoft Entra ID integration is NOT enabled** on this AKS cluster.
* **`disableLocalAccounts: false`** (shown as `"local": false` from your query) → **Local account authentication is enabled.**

The `identityProfile` output you shared is **only the managed identity used by the AKS kubelets**. It has nothing to do with how human users authenticate.

## Why your Entra user appears to have full access

Here's the important point:

You said:

> "I granted an Entra ID user Azure Kubernetes Service Cluster User Role."

That Azure role controls **who is allowed to download cluster credentials**. It does **not** magically make the cluster authenticate users with Entra ID.

Because your cluster has:

```text
aadProfile = null
```

there is **no Entra authentication configured**.

So when someone runs:

```bash
az aks get-credentials
```

AKS returns a **certificate-based kubeconfig**.

That's exactly what you saw:

```yaml
user:
  client-certificate-data: ...
  client-key-data: ...
```

When Kubernetes receives that certificate, it identifies the caller as:

```text
Username: masterclient
Groups: [system:masters]
```

And `system:masters` is Kubernetes' built-in superuser group.

So the actual flow is:

```text
Entra User
      │
      ▼
Azure checks:
"Can this person download kubeconfig?"
      │
      ▼
YES (Cluster User Role)
      │
      ▼
AKS returns certificate credentials
      │
      ▼
Kubernetes sees:
masterclient
system:masters
      │
      ▼
Full cluster-admin
```

Notice that **the Entra username is never presented to Kubernetes**, because the cluster isn't configured to use Entra authentication.

## Why this is different from a modern AKS cluster

On a modern AKS cluster with Entra integration enabled:

```text
Entra User
     │
az login
     │
kubelogin
     │
OAuth token
     │
AKS API Server
     │
Username:
david@contoso.com
     │
Kubernetes RBAC
```

In that scenario:

```yaml
subjects:
- kind: User
  name: david@contoso.com
```

works exactly as you'd expect.

Your cluster can't do that because `aadProfile` is `null`.

## Can you use Kubernetes RBAC today?

**Not for Entra users.**

Since every downloaded kubeconfig authenticates as `masterclient`, Kubernetes has no way to distinguish:

* Alice
* Bob
* David

They all appear as:

```text
masterclient
```

Any `RoleBinding` for `david@contoso.com` will never match, because Kubernetes never sees `david@contoso.com` as the authenticated user.

## What should you do?

If your goal is:

* Users sign in with Microsoft Entra ID
* Kubernetes RBAC controls namespace permissions

then the cluster needs to be **integrated with Microsoft Entra ID**. That's the supported design for AKS. Once enabled, users authenticate as their actual Entra identities and `Role`/`RoleBinding` objects can grant namespace-scoped permissions.



-----------------



## errors
>  kubectl get pods -n dev-node
NAME                                       READY   STATUS             RESTARTS   AGE
hellofromnode-deployment-9c4c47895-tjd9p   0/1     ImagePullBackOff   0          95s
- `ImagePullBackOff`: means that a container could not start because Kubernetes could not pull a container image. 
`Resolution`: Attach ACR to AKS. Wait for sometime its up. if not it is still stuck. 
```sh
kubectl rollout restart
```
is a command used to start a new rollout process for three specific Kubernetes objects: Deployment, DaemonSet, and StatefulSet. A rollout process essentially means a gradual, step-by-step recreation of Pods. [more](https://kodekloud.com/blog/kubectl-rollout-restart/)
```sh
kubectl get pods -n=dev-dotnet
kubectl describe pod podName -n=dev-dotnet
```
- describe tells ip, deployed image sha, events with timestamp
