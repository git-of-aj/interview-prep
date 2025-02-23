# Network Security 
- `Virtual network rules` enable Azure SQL Database to only accept communications that are sent from `selected subnets inside a virtual network`.
- To `allow traffic to reach Azure SQL` Database, use the SQL `service tags` to allow `outbound traffic` through `Network Security Groups`.
- `IP Firewall Rule` : list IP
- `Allow azure Services`
# Authentication 
- start with admin user -> create normal user.
- Kerberos authentication for Microsoft Entra principals enables Windows authentication for Azure SQL Managed Instance.
# permissions 
- further limit the scope of what a user can do, the `EXECUTE AS` can be used to specify the execution context of the called module.
- Row-Level Security enables customers to control access to rows in a database table based on the characteristics of the user executing a query (for example, group membership or execution context)
# Auditing 
- recording database events to an audit log in a customer-owned Azure `storage account`
# Advance Threat Protection 
- *Advanced Threat Protection can be enabled per server for an additional fee*. 
- SQL injection, potential data infiltration, and brute force attacks or for anomalies in access patterns to catch privilege escalations and breached credentials use. Alerts are viewed from the `Microsoft Defender for Cloud` : recommendations + details
