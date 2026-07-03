## Medical System - monolith or microservice?
Based on your description, I would classify this as **a distributed monolith**, not a microservices architecture.

Here's why.

| Characteristic                                                                  | Your application | Indicates                             |
| ------------------------------------------------------------------------------- | ---------------- | ------------------------------------- |
| Separate IIS sites (`portal.app.com`, `api.app.com`)                            | ✅ Yes            | Slightly service-oriented             |
| Separate processes (separate IIS application pools, assuming they are separate) | ✅ Probably       | Not a classic single-process monolith |
| Portal communicates with API over HTTP                                          | ✅ Yes            | Service boundary exists               |
| Shared database                                                                 | ✅ Yes            | Monolith/distributed monolith smell   |
| API is required for portal to function                                          | ✅ Yes            | Tight coupling                        |
| Deployments affect both applications (`iisreset`)                               | ✅ Yes            | Tight operational coupling            |
| Independent scaling                                                             | ❌ No             | Not microservices                     |
| Independent releases without affecting the other                                | ❌ Not really     | Not microservices                     |
| Independent ownership/lifecycle                                                 | ❌ No             | Not microservices                     |

### Why it isn't a classic monolith

A classic monolith would look like this:

```
Browser
   |
Single IIS Site
   |
Authentication
Orders
Products
Users
Payments
```

Everything runs in one application process.

Your setup is:

```
Browser
   |
Portal (IIS Site)
   |
HTTP
   |
API (IIS Site)
   |
Database
```

So there are two deployable applications communicating over HTTP.

That is **not** a traditional monolith.

### Why it isn't microservices

Microservices emphasize independent services. In your case:

* One shared database.
* Portal cannot function if the API is unavailable.
* `iisreset` restarts both sites.
* Deployments impact the whole system.
* Likely developed and released by the same team.

Those characteristics indicate the services are not operationally independent.

### This is what architects usually call a distributed monolith

A distributed monolith has multiple deployable applications, but they behave like one application because of tight coupling.

Typical characteristics include:

* Multiple web apps or services.
* Shared database.
* Synchronous HTTP calls everywhere.
* Coordinated deployments.
* Shared release schedule.
* One service going down causes widespread outages.

Your architecture matches this quite closely.

### About updating only a few files

This doesn't determine the architecture.

For example:

```
Copy login.aspx
Copy web.config
```

is simply a deployment technique. It doesn't make the application more modular or service-oriented.

Similarly, replacing a DLL or updating static assets doesn't change whether the architecture is monolithic or microservices-based.

### The biggest indicator

You mentioned:

> we have to do IIS reset post deployment which brings entire app down

This is a strong sign of operational coupling.

If the portal and API were truly independent, you could typically recycle only the affected application pool or deploy one application without interrupting the other. A full `iisreset` restarts all IIS sites and application pools on the server, causing a complete outage.

### My assessment

```
Classic Monolith        Distributed Monolith        Microservices
-----------------       ----------------------      ----------------
One process             Multiple apps              Independent services
One deployment          HTTP between apps          Independent deployment
One codebase            Shared database            Separate databases
                        Tight coupling             Loose coupling
                             ▲
                          Your system
```

I would estimate:

* **10%** microservice characteristics (separate API and portal communicating over HTTP).
* **90%** distributed monolith characteristics (shared database, coordinated deployments, tight runtime dependency, shared infrastructure).

If your long-term goal is modernization, this type of architecture is a common starting point. Many organizations first separate the UI and API, then gradually decouple data ownership, deployment, and scaling until they have independently deployable services.
