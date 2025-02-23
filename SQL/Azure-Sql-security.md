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
- **Dynamic data masking** limits sensitive data exposure by masking it to non-privileged users
# Auditing 
- recording database events to an audit log in a customer-owned Azure `storage account`
# Advance Threat Protection 
- *Advanced Threat Protection can be enabled per server for an additional fee*. 
- SQL injection, potential data infiltration, and brute force attacks or for anomalies in access patterns to catch privilege escalations and breached credentials use. Alerts are viewed from the `Microsoft Defender for Cloud` : recommendations + details
- Vulnerability assessment can be accessed and managed via the central Microsoft Defender for SQL portal.
# connection
- SQL Database, SQL Managed Instance, and Azure Synapse Analytics enforce encryption (SSL/TLS) at all times for all connections. This ensures all data is encrypted "in transit" between the client and server `irrespective of the setting of Encrypt or TrustServerCertificate in the connection string`.
-  best practice, recommend that in the connection string used by the application, you specify an `encrypted connection and not trust the server certificate`. This forces your application to verify the server certificate and thus prevents your application from being vulnerable to man in the middle type attacks.
-  ADO.NET driver this is accomplished via Encrypt=True and TrustServerCertificate=False. If you obtain your connection string from the Azure portal, it will have the correct settings.

# best practice:
Here's a breakdown of the key takeaways and calls to action from the Azure SQL Database security best practices document:

**Authentication**

*   **Centralize Identity Management:** Use Microsoft Entra authentication for managing identities. Create Microsoft Entra groups, assign access rights to these groups, and map them to contained database users.
*   **Implement Multifactor Authentication:** Enable multifactor authentication in Microsoft Entra ID using Conditional Access.
*   **Minimize Password-Based Authentication:** Use Microsoft Entra integrated authentication to eliminate passwords. For applications, enable Azure Managed Identity or use certificate-based authentication.
*   **Protect Passwords and Secrets:** Store passwords and secrets in Azure Key Vault and manage access through Key Vault access policies.
*   **SQL Authentication for Legacy Apps:** Use SQL authentication for legacy applications. Create logins and users as a server or instance admin.

**Access Management**

*   **Implement Principle of Least Privilege:** Assign only the necessary permissions to complete tasks. Use granular permissions, user-defined database roles, and Azure custom roles.
*   **Implement Separation of Duties:** Split sensitive tasks among different users to prevent data breaches. Use Azure roles, server roles, and database roles. Implement TDE with customer-managed keys in Azure Key Vault and Always Encrypted with role separation.
*   **Perform Regular Code Reviews:** Implement a segregated code deployment process and have a separate person inspect the code for potential security risks before deployment.

**Data Protection**

*   Safeguard important information from compromise by encryption or obfuscation.

Citations:
[1] https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice?view=azuresql


