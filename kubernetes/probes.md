# Kubernetes Readiness Probes - based on real ODM AKS error
> AKS ==> Left side ==> Events u see all AKS events for all namespace (even if can't run kubectl due to permisisons)

## 1. Readiness Probe Error

### Error

```text
Readiness probe failed:

Get "http://10.201.4.223:8080/actuator/health/readiness":

dial tcp 10.201.4.223:8080:
connect: connection refused
````

### Kubernetes Event

```
 | Field | Value |
| --- | --- |
| Status | `Warning` |
| Reason | `Unhealthy` |
| Source | `kubelet, aks-nodepool-11096307-vmss000000` |
| Pod | `cg-ai-integration-service-85c7cb6464-84pqp` |
| Namespace | `cg` |
| Count | `1` |
| Timestamp | `2026-09-16T11:25:55Z` |
```
---

 ## 2\. What Does the Error Mean?

 The readiness probe was trying to access:


http://10.201.4.223:8080/actuator/health/readiness


 The important part is:

```
connect: connection refused
```

 This means the TCP connection to port `8080` was refused.

 ### Think of the request as 4 layers

```
Layer 1: Can I reach the IP?
          ↓
Layer 2: Can I establish a TCP connection to port 8080?
          ↓
Layer 3: Can I make an HTTP request?
          ↓
Layer 4: Does /actuator/health/readiness return healthy?
```

 The failure occurred at **Layer 2**.

```
10.201.4.223:8080
       ↓
TCP connection
       ↓
❌ Connection refused
```

 The operating system is essentially saying:

 > Nobody is listening on port 8080.

 This is different from an HTTP-level failure such as:

```
HTTP 500
HTTP 503
```

 In this case, the HTTP request was never successfully established.

---

 # 3\. Readiness Probe

 A **readiness probe** tells Kubernetes:

 > "Is my application ready to receive traffic right now?"

 If the readiness probe fails, Kubernetes considers the Pod **NotReady** and stops sending Service traffic to that Pod.

 ### Probe Types

 | Probe | Question it answers | If it fails |
| --- | --- | --- |
| **Readiness** | "Can I send traffic to you?" | Stop sending traffic |
| **Liveness** | "Are you still alive?" | Restart the container |
| **Startup** | "Have you finished starting?" | Give startup more time |

### Important

 These probes do **not** have to follow one fixed sequence in every configuration.

 A common lifecycle looks like this:

```
Deployment created
      ↓
Pod scheduled
      ↓
Container starts
      ↓
Startup probe runs
      ↓
Application finishes starting
      ↓
Readiness probe runs
      ↓
Pod becomes READY
      ↓
Service sends traffic
      ↓
Liveness + readiness continue running
```

---

 # 4\. How the Readiness Failure Can Lead to Pod Deletion

 A simplified sequence can look like this:

```
Application becomes unhealthy
        ↓
Readiness probe fails
        ↓
Pod becomes NotReady
        ↓
Deployment / ReplicaSet may create replacement Pods
        ↓
Old Pod may be terminated
        ↓
Pod is deleted
```

 > **Important:** A failed readiness probe by itself does not necessarily mean Kubernetes immediately deletes the Pod.

 Readiness primarily controls whether the Pod receives traffic.

 Pod termination/deletion can happen for other reasons, such as:

 - Deployment rollout
- ReplicaSet replacement
- Scaling
- Node issues
- Manual deletion
- Eviction
- Container/application failures
- Other controller actions

---

 # 5\. PreStopHook Failed

 You may also see:

```
PreStopHook failed
```

 ### What is a PreStop hook?

 A `PreStop` hook is an action Kubernetes asks the container to execute **before terminating it**.

 Conceptually:

```
Kubernetes decides to terminate Pod
              ↓
       PreStop hook runs
              ↓
       Container terminates
```

 Therefore:

```
PreStopHook failed
```

 basically means:

 > Kubernetes tried to perform the application's shutdown/pre-stop action, but that action did not complete successfully.

 ### Important distinction

 The `PreStopHook` failure does **not necessarily mean it caused the original readiness-probe problem**.

 For example:

```
Application has a problem
        ↓
Readiness probe starts failing
        ↓
Pod is eventually terminated
        ↓
PreStop hook runs
        ↓
PreStop hook also fails
```

 In this scenario, the PreStop failure is a **symptom during termination**, rather than the original cause of the application's unhealthy state.

---

 # 6\. Spring Boot Actuator

 The readiness endpoint:

```
/actuator/health/readiness
```

 is commonly provided by **Spring Boot Actuator**.

 Reference:

 https://www.baeldung.com/spring-boot-actuators

 A typical readiness probe might look like:

```
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
```

 The important requirement is that the application must actually be listening on the configured port.

 For example:

```
Kubernetes
    ↓
10.201.4.223:8080
    ↓
Spring Boot application
    ↓
/actuator/health/readiness
```

 If nothing is listening on `8080`, Kubernetes gets:

```
connection refused
```

---

 # 7\. Troubleshooting `connection refused`

 Because this failure occurred at the TCP layer, start by checking whether the application is actually listening on port `8080`.

 ### Check the Pod

```
kubectl get pod <pod-name> -n <namespace>
```

 ### Describe the Pod

```
kubectl describe pod <pod-name> -n <namespace>
```

 Look for:

 - Readiness probe configuration
- Container port
- Events
- Restart count
- Termination reason
- PreStop hook
- Startup probe
- Liveness probe

 ### Check application logs

```
kubectl logs <pod-name> -n <namespace>
```

 For a previous crashed container:

```
kubectl logs <pod-name> -n <namespace> --previous
```

 ### Check whether the container is listening on port 8080

 If the image contains the necessary tools:

```
kubectl exec -it <pod-name> -n <namespace> -- \
  sh -c 'ss -lntp'
```

 Or:

```
kubectl exec -it <pod-name> -n <namespace> -- \
  sh -c 'netstat -lntp'
```

 You want to see something listening on:

```
0.0.0.0:8080
```

 or potentially:

```
:::8080
```

---

 # 8\. Common Causes of `Connection Refused`

 For this particular error:

```
connect: connection refused
```

 possible causes include:

 ### Application has not started yet

```
Container starts
      ↓
Spring Boot still initializing
      ↓
Port 8080 not listening yet
      ↓
Readiness probe
      ↓
Connection refused
```

 This is one reason a **startup probe** can be useful for applications with slow startup times.

---

 ### Application crashed

```
Container starts
      ↓
Application starts
      ↓
Application crashes
      ↓
Port 8080 stops listening
      ↓
Readiness probe
      ↓
Connection refused
```

 Check:

```
kubectl logs <pod-name> -n <namespace>
```

---

 ### Wrong application port

 For example, Kubernetes checks:

```
8080
```

 but the application is actually listening on:

```
8081
```

 Then:

```
Kubernetes → :8080 ❌
Application → :8081 ✅
```

 Check the Spring Boot configuration and Kubernetes manifest.

---

 ### Application only listening on another interface

 For example:

```
127.0.0.1:8080
```

 instead of:

```
0.0.0.0:8080
```

 This can cause connectivity problems depending on how the probe reaches the application.

---

 ### Probe configuration is incorrect

 For example:

```
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
```

 but the application uses a different:

 - Port
- Management port
- Context path
- Actuator configuration
- Protocol

---
