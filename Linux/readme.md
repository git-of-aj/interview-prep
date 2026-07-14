# Troubleshooting

#### Check Port Connectivity 
1. nmap
```sh
nmap -p 1433 10.0.0.4
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-14 20:13 +0000
Nmap scan report for 10.0.0.4
Host is up (0.0018s latency).

PORT     STATE SERVICE
1433/tcp open  ms-sql-s

Nmap done: 1 IP address (1 host up) scanned in 0.63 seconds
```
2. nc -zv or telnet <ip> <port>
```sh
nc -zv 10.0.0.4 22 
Connection to 10.0.0.4 22 port [tcp/ssh] succeeded!
```
3. HTTP/HTTPS => Master `CURL`
```sh
 curl -i -L -v -X GET http://20.204.200.159/env

Note: Unnecessary use of -X or --request, GET is already inferred.
*   Trying 20.204.200.159:80...
* Established connection to 20.204.200.159 (20.204.200.159 port 80) from 10.244.1.110 port 36640 
* using HTTP/1.x
> GET /env HTTP/1.1
> Host: 20.204.200.159
> User-Agent: curl/8.21.0
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< date: Tue, 14 Jul 2026 20:02:22 GMT
date: Tue, 14 Jul 2026 20:02:22 GMT
< server: uvicorn
server: uvicorn
< content-length: 80
content-length: 80
< content-type: application/json
content-type: application/json
< 

* Connection #0 to host 20.204.200.159:80 left intact
{"NAME":null,"DATABASE_PASSWORD":null,"DATABASE_USER":null,"DATABASE_HOST":null}#
```
4. Firewall Issue
```sh
traceroute 10.0.0.4
traceroute to 10.0.0.4 (10.0.0.4), 30 hops max, 46 byte packets
 1  aks-agentpool-26618324-vmss000000.internal.cloudapp.net (10.224.0.5)  0.007 ms  0.004 ms  0.005 ms
 2  10.0.0.4 (10.0.0.4)  2.627 ms  1.357 ms  1.396 ms
```  
