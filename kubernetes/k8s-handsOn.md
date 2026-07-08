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