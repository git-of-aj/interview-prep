[3rd Party blog Link](https://www.spectrocloud.com/blog/troubleshooting-the-top-10-kubernetes-errors)

# `kubectl logs` vs `kubectl describe pod`
**Rule of thumb:**
* **logs** = *"What did my application say?"*
* **describe** = *"What did Kubernetes do?"*

## Quick Summary

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

## Comparison

| Command                      | Use it for         | Shows                                                                                        |
| ---------------------------- | ------------------ | -------------------------------------------------------------------------------------------- |
| `kubectl logs <pod>`         | Application issues | Output written by the container (`stdout`/`stderr`)                                          |
| `kubectl describe pod <pod>` | Kubernetes issues  | Pod events, scheduling, image pulls, probes, volumes, resource limits, restart reasons, etc. |

***

## Use `kubectl logs` When

* The application is crashing or throwing exceptions.
* You need stack traces or application errors.
* You want logs from a running container.

### Examples

```bash
kubectl logs my-pod
kubectl logs my-pod -c nginx
kubectl logs --previous my-pod # get logs for previsoly failed pods
```

***

## Use `kubectl describe` When

* The pod is stuck in `Pending`, `CrashLoopBackOff`, or `ImagePullBackOff`.
* You need to know why Kubernetes isn't running the pod correctly.
* You want to review recent Events and pod configuration.

### Example

```bash
kubectl describe pod my-pod
```

***

## Easy Way to Remember



***

## Typical Troubleshooting Order

### 1. Check Pod Status

```bash
kubectl get pods
```

### 2. Inspect Kubernetes Events and Pod State

```bash
kubectl describe pod <pod>
```

### 3. Review Application Logs

```bash
kubectl logs <pod>
```

### 4. Perform Deep Investigation (if required)

```bash
kubectl exec -it <pod> -- /bin/sh
```


