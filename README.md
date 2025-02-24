# interview-prep

[must check linux questiions](https://zerotomastery.io/blog/linux-interview-questions/)

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
