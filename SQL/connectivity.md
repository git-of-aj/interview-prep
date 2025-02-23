![image](https://github.com/user-attachments/assets/519fc147-a7d8-41b4-8855-6cf1b785fc71)

_steps describe how a connection is established to Azure SQL Database:_

- Clients connect to the gateway that has a public IP address and listens on port 1433.
- Depending on the effective connection policy, the gateway redirects or proxies the traffic to the correct database cluster.
- Inside the database cluster, traffic is forwarded to the appropriate database.
1. **Redirect** Method Recommended :
   - connect directly to node having db
   - From Azure VM (client) in NSG `ALLOW outbound traffic` Service Tags for SQL (list of IP from that region aka gateway IP)
   - check [docs](https://www.microsoft.com/download/details.aspx?id=56519) to know SQL's range of IP in that REGION
2. **Proxy**
 leading to increased latency and reduced throughput. 
3. **Default** Policy
   The default policy is Redirect for all client connections originating inside of Azure (for example, from an Azure Virtual Machine) and Proxy for all client connections originating outside (for example, connections from your local workstation).
