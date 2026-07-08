## networking
- [nodeport, ext ip etc - ms docs](https://learn.microsoft.com/en-us/azure/aks/concepts-network-services)
- Virtual network integration allows you to deploy dedicated instances of a service into a virtual network. Services can then be privately accessed within the virtual network and from on-premises network
- general recommendation is to use a public cluster. [ms docs](https://learn.microsoft.com/en-us/azure/aks/plan-control-plane-networking)
- Once generally available (GA), we recommend enabling API Server VNet Integration for both public and private clusters to enhance security and simplify network management.
- **FOr Node Networking:**
- Our general recommendation is to use a Load Balancer. If you have a high volume of outbound connections, consider using a NAT Gateway for better SNAT port management. If you have any custom egress needs (Azure Firewall, NVA, etc.), you might want to explore User Defined Routing (UDR).
- **For Pod Networking**:
- general recommendation is to use `Azure CNI Overlay`. If you need direct IP access and have efficiency or scale requirements, consider using Azure CNI Pod Subnet with Dynamic IP Allocation or Azure CNI Pod Subnet with Static Block Allocation. If you need direct
- **For External Access to App hosted on AKS**:
- For non-HTTP traffic, we recommend using Load Balancer Service with layer-4 load balancing. 

## Upgrade
- When you upgrade your AKS cluster, a new node is deployed in the cluster. Services and workloads begin to run on the `new node`, and an older node is removed from the cluster
