[3rd Party blog Link](https://www.spectrocloud.com/blog/troubleshooting-the-top-10-kubernetes-errors)

### App logs
- Multiple pods are running behind a service....... Don't know which pod will recieve traffic so
```sh
kubectl logs -f -l app=my-app
```
### Services
- If `label`:`value` is not exactly matching with deployment.yml then svc running but no traffic routing to pods
- To verify: `kubectl get endpointslices`
```sh
## HEALTHY
NAME                ADDRESSTYPE   PORTS   ENDPOINTS                                            AGE
internal-lb-rcf76   IPv4          8000    10.244.1.145,10.244.1.110,10.244.0.136 + 2 more...   2m50s
kubernetes          IPv4          443     20.207.113.214                                       85m

## UNHEALTHY
kubectl get endpointslices
NAME                ADDRESSTYPE   PORTS     ENDPOINTS        AGE
internal-lb-rcf76   IPv4          <unset>   <unset>          111s
kubernetes          IPv4          443       20.207.113.214   84m

------ MATCH LABELS -------
 k get svc -o wide
NAME          TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE    SELECTOR
internal-lb   LoadBalancer   10.0.175.220   20.204.200.159   80:30493/TCP   3m5s   app=api,env=dev
kubernetes    ClusterIP      10.0.0.1       <none>           443/TCP        85m    <none>

k get deploy -o wide
NAME             READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
api-deployment   5/5     5            5           28m   api          acr8r.azurecr.io/api:v1.1   app=api,env=dev
```
- EndpointSlices include references to all the Pods that match the Service selector


##### `kubectl logs` vs `kubectl describe pod`
**Rule of thumb:**
* **logs** = *"What did my application say?"*
* **describe** = *"What did Kubernetes do?"*

#### Quick Summary

```text
kubectl get pods
        ↓
kubectl describe pod <pod>
        ↓
kubectl logs <pod>
        ↓
kubectl exec -it <pod> -- /bin/sh
```

They serve different purposes and are often used together during troubleshooting.

#### Comparison

| Command                      | Use it for         | Shows                                                                                        |
| ---------------------------- | ------------------ | -------------------------------------------------------------------------------------------- |
| `kubectl logs <pod>`         | Application issues | Output written by the container (`stdout`/`stderr`)                                          |
| `kubectl describe pod <pod>` | Kubernetes issues  | Pod events, scheduling, image pulls, probes, volumes, resource limits, restart reasons, etc. |

***

#### Use `kubectl logs` When

* The application is crashing or throwing exceptions.
* You need stack traces or application errors.
* You want logs from a running container.

##### Examples

```bash
kubectl logs my-pod
kubectl logs my-pod -c nginx
kubectl logs --previous my-pod # get logs for previsoly failed pods
```

***

#### Use `kubectl describe` When

* The pod is stuck in `Pending`, `CrashLoopBackOff`, or `ImagePullBackOff`.
* You need to know why Kubernetes isn't running the pod correctly.
* You want to review recent Events and pod configuration.

##### Example

```bash
kubectl describe pod my-pod
```

***

#### Easy Way to Remember



***

#### Typical Troubleshooting Order

##### 1. Check Pod Status

```bash
kubectl get pods
```

##### 2. Inspect Kubernetes Events and Pod State

```bash
kubectl describe pod <pod>
```

##### 3. Review Application Logs

```bash
kubectl logs <pod>
```

##### 4. Perform Deep Investigation (if required)

```bash
kubectl exec -it <pod> -- /bin/sh
```


