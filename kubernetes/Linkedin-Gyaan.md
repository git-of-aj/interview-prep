### [Post](https://www.linkedin.com/feed/update/urn:li:activity:7484124997439946752/): Govardhana — Syed says `kubectl` is completely replaced with GitOps

Learned this from a $600K Google engineer.

Never run `kubectl apply` without this checklist.

**0> `kubectl apply --dry-run=server -f manifest.yaml`** → validate the manifest against the API server without changing live resources.

**1> `kubectl diff -f manifest.yaml`** → see exactly what will change.

**2> `kubectl get all,cm,secret,ingress,pvc -n <namespace>`** → full snapshot of the current state (`kubectl get all` skips ConfigMaps, Secrets, Ingresses, and PVCs).

**3> `kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp`** → catch existing warnings and errors before adding more.

**4> `kubectl apply -f manifest.yaml --dry-run=server`** → validate the full apply request against the API without touching live resources.

**5> `kubectl apply --validate=strict -f manifest.yaml`** → catch YAML schema and validation errors early.

**6> `kubectl describe configmap <name> -n <namespace>`** → ensure required configuration values exist.

**7> `kubectl get secret <name> -n <namespace> -o jsonpath='{.data}'`** → confirm the Secret exists and contains the expected keys.

**8> `kubectl describe quota -n <namespace>`** → verify resource quotas won't block the deployment.

**Tip:** Wrap all of these into a `Makefile` target (`make precheck`) so `kubectl apply` cannot run until every check passes.

At first, this feels like overkill. Wouldn't it slow deployments down?

In practice, it does the opposite.

* No more blind applies.
* Confidence in every rollout.
> Pro Tip: 
* Trigger these checks automatically for every PR targeting the `main` branch.
* Merge only after all checks pass. Once manifests are merged into `main`, GitOps tools like ArgoCD deploy them to the cluster.
* These are only the minimum baseline.
* Add more validations for production readiness, such as health probes, resource requests/limits, network policies, and other required configurations to avoid impacting dependent services.
* Safer production deployments.

One prevented outage can save hours of firefighting.
---
```sh
--dry-run=client only validates locally using the kubectl client.
```
```
--dry-run=server 
```
validates against the actual cluster, so it catches issues such as:
- Missing CRDs
- Invalid API versions
- Admission policy violations
- Cluster-specific validation rules
- Server-side defaults and mutations
