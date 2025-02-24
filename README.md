# interview-prep - PKI trust model

[must check linux questiions](https://zerotomastery.io/blog/linux-interview-questions/)

> If your SQL Server and client are on a private network and you trust the network, you don’t need a public CA-issued certificate.
> you'll need to configure the client machines to explicitly trust the certificate (i.e., add the certificate to their trusted root store).
> use internal CA Active Directory Certificate Services (ADCS) in Windows Server), you can issue certificates from this internal CA to both the SQL Server and clients.
# TLS - sits b/w layer 7 & 4 -- highest version preferred
> Starting with SQL Server 2016 (13.x), Secure Sockets Layer (SSL) has been discontinued.
- TLS/SSL protocols use algorithms from a cipher suite to create keys and encrypt information
- secure and send application data to the transport layer.
-  The client and server negotiate the protocol version and cipher suite to be used for encryption during the initial connection (pre-login) phase of connection establishment
-  **Digital certificates** are electronic files that work like an online password to verify the identity of a user or a computer
Digital certificates provide the following services:

1. Encryption: They help protect the data that's exchanged from theft or tampering.
2. Authentication: They verify that their holders (people, web sites, and even network devices such as routers) are truly who or what they claim to be. Typically, the authentication is one-way, where the source verifies the identity of the target, but mutual TLS authentication is also possible.
>  most typical SQL Server connections using TLS, the `client` uses the **server's public key** to establish a secure connection, and the server uses its private key to decrypt and respond.

# Admin consent vs user 
Let's say you have 500 users in your Azure AD tenant, and you want all of them to authenticate to SQL Server using their Azure AD credentials.

When the admin sets up Azure AD Authentication for SQL Server, they would grant admin consent for permissions like User.Read.All and Directory.Read.All. These permissions allow SQL Server to:

Retrieve the information about all users in the organization (not just a specific user).
Verify the identity of anyone attempting to log in (e.g., check if the user exists in the directory and confirm their group memberships).
Without Admin Consent: If only user consent were allowed, each of the 500 users would need to manually approve access to their personal data, which is impractical and inefficient for a company with many users.
