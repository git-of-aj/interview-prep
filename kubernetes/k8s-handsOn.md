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
