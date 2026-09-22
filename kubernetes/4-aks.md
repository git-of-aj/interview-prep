### Scaling
- Kubernetes supports manual scaling of workloads.
- Horizontal scaling (available by default) can be done using the kubectl CLI.
- For vertical scaling, you need to patch the resource definition of your workload.
- VPA doesn't come with Kubernetes by default, but is a an add-on that you or a cluster administrator may need to deploy before you can use it.
- You will need to have the Metrics Server installed to your cluster for the VPA to work.
> why use HPA when u can edit replica in deployment yaml
```yml
Deployment replicas yaml file:
"I want N Pods."

HPA:
"I want between MIN and MAX Pods,
and Kubernetes should decide N based on metrics."

kubectl autoscale deployment php-apache --cpu=50% --min=1 --max=10
OR
kubectl get hpa
OR YAML: 

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 3
  maxReplicas: 10

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

```
- This is important: HPA doesn't require all conditions to be true simultaneously. It evaluates each configured metric and uses the metric that results in the highest desired replica count.
```yml
  spec:
  minReplicas: 2
  maxReplicas: 10

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```
