## Pending

install gateway api crd + envoy controller
https://gateway.envoyproxy.io/docs/concepts/
https://spacelift.io/blog/kubernetes-cheat-sheet
link: https://www.spectrocloud.com/blog/troubleshooting-the-top-10-kubernetes-errors

gateway controller is a pod in NS

kubectl get logs
kubectl get crds -A
flags like watch (-w)

good practice to create your service account else deployment use default

A CRD is the definition of a custom resource type. A custom resource is an instance of that type. For example: Database CRD: Defines the Database API type. orders-db custom resource: A specific Database object created from that CRD.

kubectl debug
k8s upgrade
k8s kv integration
k8s troubleshooting

stop new schedules = cordon nodes
check release notes = change in how it works
upgrade can't be downgrade
2 week buffer in lower env

control plane and worker nodes == should have same k8s version

cluster autoscalar should have same version as k8s control plane

atleast 5 available ip in subnet

kubelet should also match k8s version

control plane >> nodepool [data plane - most time consuming & critical]>> add ons (upgrade flow)

Helm 4 - The package manager for Kubernetes

An Istio VirtualService is a custom resource definition (CRD) that defines advanced traffic routing rules for a Kubernetes service. Instead of replacing the standard Kubernetes Service, it builds on top of it to enable granular application-layer routing (like HTTP headers, URL paths, and methods), canary deployments, retries, and fault injection

observability - phoenix Kubernetes + Grafana + Prometheous + Kiali is the visual dashboard for an Istio service mesh on Kubernetes. It acts as an "X-ray machine" for your microservices. It shows exactly how they talk to each other, how fast they are, and where errors happen. + Jaeger is an open-source distributed tracing platform used to monitor and troubleshoot complex microservices architectures in Kubernetes. It tracks request lifespans across multiple network boundaries, helping developers pinpoint latency bottlenecks and system failures.
openFGA - OpenFGA is an open-source authorization solution that allows developers to build granular access control using an easy-to-read modeling language and friendly APIs.


