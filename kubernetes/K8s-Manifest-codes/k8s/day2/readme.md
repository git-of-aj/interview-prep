```sh
kubectl config set-context --current --namespace=nginx-app
k apply -k .
 curl http://serviceIP/env
```

### azure.workload.identity/client-id
When you attach this annotation to a Kubernetes ServiceAccount, you supply the Application (Client) ID of a User-Assigned Managed Identity or a Microsoft Entra App Registration. This bridges the Kubernetes application identity with your Azure identity.

### 
