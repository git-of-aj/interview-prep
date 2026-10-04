## App Service 
- `Health checks`: Just ping every min the app at /given-path if response 200-299, underlying instace healthy, even 301 (redirect) unhealthy, Only if you using more than 1 instance, its replaced, else continue on unhealthy  [scaleout]

## Azure vm
- Create state isolation. Workload data should be on a separate data disk to prevent interference with the OS disk. If a VM fails, you can create a new OS disk with the same data disk, which ensures resilience and fault isolation.

## Springboot app
- [Springboot is recommended over dockerfile](https://cloud.google.com/blog/topics/developers-practitioners/comparing-containerization-methods-buildpacks-jib-and-dockerfile)