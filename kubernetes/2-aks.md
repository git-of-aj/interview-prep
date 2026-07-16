### Config Map
>  decouple environment-specific configuration from your container images, so that your applications are easily portable.
- A ConfigMap is an API object used to store non-confidential data in key-value pairs.
- You can write a Pod spec that refers to a ConfigMap and configures the container(s) in that Pod based on the data in the ConfigMap.
- The Pod and the ConfigMap must be in the same namespace.
- Mounted ConfigMaps are updated automatically. the total delay from the moment when the ConfigMap is updated to the moment when new keys are projected to the Pod can be as long as the kubelet sync period + cache propagation delay, where the cache propagation delay depends on the chosen cache type (it equals to watch propagation delay, ttl of cache, or zero correspondingly).

| Situation                        | Best choice            | Example                                                                                                                                                        |
| -------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Simple key-value configuration   | Environment variables  | `LOG_LEVEL=INFO`, `APP_ENV=prod`                                                                                                                               |
| Application uses CLI flags       | Command-line arguments | `--port=8080`, `--debug=false`                                                                                                                                 |
| Application expects config files | Volume mount           | `nginx.conf`, `application.yml`, `prometheus.yml`, `haproxy.cfg`                                                                                               |
| Large structured configuration   | Volume mount           | YAML, JSON, XML, INI files                                                                                                                                     |
| Configuration changes frequently | Volume mount           | Mounted ConfigMaps can be updated on disk without recreating the ConfigMap itself, though whether the application picks up changes depends on the application. |

4 ways to declare config:
1. Inside a container command and args
2. Environment variables for a container
3. Add a file in read-only volume, for the application to read
4. Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap
- for first 3 kubelet uses the data from the ConfigMap when it launches container(s) for a Pod.
note:
A ConfigMap is not designed to hold large chunks of data. The data stored in a ConfigMap cannot exceed 1 MiB. If you need to store settings that are larger than this limit, you may want to consider mounting a volume or use a separate database or file service.
