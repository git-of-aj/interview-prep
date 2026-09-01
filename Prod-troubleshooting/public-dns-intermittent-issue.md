# DNS Troubleshooting Revision Notes — pension.isdb.org

commands here: https://gist.github.com/Trainer-AJ/95c6123b90ba7a20d23bb018abb87d88

## 1. First understand the request flow

For this environment, the expected flow is:

```text
User / Browser
      |
      | 1. DNS lookup: pension.isdb.org
      v
DNS Resolver
168.63.129.16
      |
      | 2. Find authoritative DNS
      v
Authoritative DNS servers
      |
      | 3. Return 20.196.5.33
      v
FortiWeb WAF
20.196.5.33
      |
      | 4. Forward request
      v
SharePoint 2019 / IIS

```

**Critical troubleshooting principle**

If DNS fails:
`pension.isdb.org → NXDOMAIN → STOP`

The request never reaches FortiWeb or SharePoint. Therefore, always troubleshoot top-down:
**DNS → FortiWeb → IIS/SharePoint**

---

## 2. What is NXDOMAIN?

`NXDOMAIN` = Non-Existent Domain. It means the DNS server is saying: *"This DNS name does not exist."*

Example:
`pension.isdb.org → NXDOMAIN` means the resolver/authoritative server cannot find that DNS name.

It is different from:

* `NOERROR` + no A record
* `timeout`
* `connection refused`
* `HTTP 500`
* `HTTP 502`

**Remember:** `NXDOMAIN` = DNS name does not exist according to that DNS server. If DNS returns `NXDOMAIN`, don't start with SharePoint troubleshooting.

---

## 3. The important dig flags

When troubleshooting DNS, these are the most useful fields:

* `status: NOERROR`
* `status: NXDOMAIN`
* `flags: qr aa rd`

**AA (`aa` = Authoritative Answer)**
This is extremely important. If you directly query a DNS server and get:

```text
status: NXDOMAIN
flags: qr aa rd

```

Then that server itself is authoritative and is saying: *"According to my authoritative copy of the zone, this name doesn't exist."* That's much stronger evidence than an ordinary recursive DNS failure.

**QR (`qr`)** = This is a DNS response.

**RD (`rd` = Recursion Desired)**
You asked the DNS server to perform recursion. If you query an authoritative-only server, you may see:
`WARNING: recursion requested but not available`

That is not the problem. It simply means: *"You asked me to recurse, but I don't provide recursive DNS."* For authoritative testing, that's normal.

---

## 4. The commands to remember

**Step 1 — Test normal DNS resolution**

```bash
nslookup pension.isdb.org

```

or:

```bash
dig pension.isdb.org A

```

If you get `pension.isdb.org → 20.196.5.33`, DNS is resolving at that moment. If you get `NXDOMAIN`, investigate DNS.

**Step 2 — Test the specific A record**
This is better than relying on normal nslookup output:

```bash
nslookup -type=A pension.isdb.org 168.63.129.16

```

or:

```bash
dig @168.63.129.16 pension.isdb.org A

```

**Why A?** Because an A record maps a hostname to an IPv4 address. In your environment:
`pension.isdb.org → A record → 20.196.5.33`

---

## 5. Why we used 168.63.129.16

`168.63.129.16` is the special Azure platform IP used for Azure-provided DNS/name resolution.

So:

```bash
dig @168.63.129.16 pension.isdb.org A

```

tests the Azure DNS resolver path. It does **not** mean that `168.63.129.16` is authoritative for `isdb.org`.

---

## 6. The most important troubleshooting technique: query authoritative DNS directly

First find the authoritative servers:

```bash
dig isdb.org NS +short

```

Suppose you discover:

* `ns1.go.com.sa`
* `ns2.go.com.sa`
* `ns1.itc.net.sa`
* `ns2.itc.net.sa`

Don't stop there. Query each server directly:

```bash
dig @ns1.go.com.sa pension.isdb.org A
dig @ns2.go.com.sa pension.isdb.org A
dig @ns1.itc.net.sa pension.isdb.org A
dig @ns2.itc.net.sa pension.isdb.org A

```

This bypasses the recursive resolver and tells you what each authoritative DNS server believes.

---

## 7. Our actual incident — the evidence

We discovered:

* `ns1.go.com.sa → NXDOMAIN`
* `ns2.go.com.sa → NXDOMAIN`

But:

* `ns1.itc.net.sa → pension.isdb.org A 20.196.5.33`
* `ns2.itc.net.sa → pension.isdb.org A 20.196.5.33`

And all four servers returned:
`matchmaking.isdb.org A 20.196.5.33`

Therefore:

```text
                 pension.isdb.org
                        |
          +-------------+-------------+
          |                           |
          v                           v
       GO DNS                      ITC DNS
          |                           |
       NXDOMAIN                   20.196.5.33

```

This is **authoritative DNS inconsistency**.

---

## 8. Why matchmaking was an excellent comparison

We used `matchmaking.isdb.org` as a control.

**Results:**

* **GO DNS:** `matchmaking → 20.196.5.33`
* **ITC DNS:** `matchmaking → 20.196.5.33`

**So:**

* DNS infrastructure exists.
* `isdb.org` zone exists.
* FortiWeb IP is valid.
* DNS servers can resolve other applications.
* Problem is specifically with `pension.isdb.org`.

This is why comparison with a known-working hostname using the same WAF is extremely useful.

---

## 9. SOA — what is it?

Run:

```bash
dig @ns1.go.com.sa isdb.org SOA

```

`SOA` = Start of Authority. It gives important information about the DNS zone.

Typical format:
`isdb.org. IN SOA ns1.go.com.sa. ispsupport.go.com.sa. 2026041542 3600 600 1209600 3600`

**Important fields:**

* `MNAME` = primary/source DNS server
* `SERIAL` = zone version
* `REFRESH` = secondary refresh interval
* `RETRY` = retry interval
* `EXPIRE` = expiry time
* `MINIMUM` = relevant to negative caching

---

## 10. Our SOA results were the biggest clue

**GO DNS:**

* `MNAME = ns1.go.com.sa`
* `SERIAL = 2026041542`

**ITC DNS:**

* `MNAME = ns1.itc.net.sa`
* `SERIAL = 1580`

**Therefore:**

* **GO DNS:** `isdb.org → zone version 2026041542`
* **ITC DNS:** `isdb.org → zone version 1580`

These are very different zone versions. Also notice the `MNAME` differs (`GO → ns1.go.com.sa`, `ITC → ns1.itc.net.sa`). That suggests these may be two independently maintained DNS infrastructures/zones, or an old/new DNS architecture that hasn't been fully synchronized/migrated.

---

## 11. Why an OLD record can be the one that breaks

`pension.isdb.org` is one of the oldest DNS records, while `matchmaking` was added last year. That does not guarantee that every DNS copy still contains pension.

**Possible history:**

```text
Old DNS system
      |
      +-- pension
      +-- other old records

```

Then DNS infrastructure changes:

```text
New DNS system
      |
      +-- zone migrated
      +-- some records copied
      +-- new records added

```

If pension was accidentally omitted during migration:

* **Old/ITC zone:** `pension → 20.196.5.33`
* **New/GO zone:** `pension → NXDOMAIN`

Then later someone adds `matchmaking → 20.196.5.33` to both systems.

**Result:**

* **pension:** `GO → ❌`, `ITC → ✅`
* **matchmaking:** `GO → ✅`, `ITC → ✅`

So old records can actually be more vulnerable to historical migration/configuration issues.

---

## 12. Why the problem can be intermittent

Suppose a recursive DNS resolver asks `GO DNS`. It gets `NXDOMAIN`. The user fails (`pension.isdb.org → NXDOMAIN`). But another resolver/query may reach `ITC DNS` and get `20.196.5.33`. Then the site works.

Therefore:

```text
               pension.isdb.org
                      |
                Recursive DNS
                      |
             +--------+--------+
             |                 |
             v                 v
          GO DNS            ITC DNS
             |                 |
          NXDOMAIN        20.196.5.33
             |                 |
          FAILURE           SUCCESS

```

DNS caching can make this even more confusing because recursive resolvers can cache both positive and negative answers.

---

## 13. How to prove the problem is DNS and not FortiWeb

This is an excellent test:

```bash
curl -vk --resolve pension.isdb.org:443:20.196.5.33 https://pension.isdb.org/

```

`--resolve` tells curl: *"For pension.isdb.org, connect directly to 20.196.5.33; don't depend on DNS."*

So you're testing:

```text
Client
  |
  | DNS bypassed
  |
  v
20.196.5.33
  |
  v
FortiWeb
  |
  v
SharePoint

```

Compare with:

```bash
curl -vk https://pension.isdb.org/

```

which uses normal DNS.

**Interpretation:**

* If **normal curl** → intermittent failure, and `--resolve curl` → consistently works, that's very strong evidence of a DNS problem.
* If `--resolve curl` → also fails, then continue down the stack toward FortiWeb/backend.

---

## 14. Full troubleshooting decision tree

```text
User reports: "pension.isdb.org is intermittent"
             |
             v
       STEP 1: DNS
             |
             v
dig pension.isdb.org A
             |
       +-----+-----+
       |           |
      OK       NXDOMAIN
       |           |
       |           +----> Investigate authoritative DNS
       |                        |
       |                        v
       |                   dig @NS hostname A
       |                        |
       |                   Do servers agree?
       |                   /               \
       |                 YES               NO
       |                  |                 |
       |                  |                 v
       |                  |         DNS inconsistency
       |                  |
       v                  |
 STEP 2: FortiWeb <-------+
       |
       v
curl --resolve ...
       |
       +---- works ----> DNS likely problem
       |
       +---- fails
             |
             v
      Check FortiWeb logs
             |
             v
      Did FortiWeb receive request?
         /               \
        NO               YES
        |                 |
        v                 v
   Network/WAF    Backend connectivity
                          |
                          v
                     IIS/SharePoint

```

---

## 15. Commands I would keep as your emergency checklist

* **Basic DNS:**
```bash
nslookup pension.isdb.org
nslookup -type=A pension.isdb.org 168.63.129.16

```


* **Better DNS analysis:**
```bash
dig pension.isdb.org A
dig @168.63.129.16 pension.isdb.org A

```


* **Find authoritative servers:**
```bash
dig isdb.org NS +short

```


* **Query authoritative servers directly:**
```bash
dig @<NS1> pension.isdb.org A
dig @<NS2> pension.isdb.org A
dig @<NS3> pension.isdb.org A

```


* **Check zone version:**
```bash
dig @<NS1> isdb.org SOA
dig @<NS2> isdb.org SOA

```


*(Compare MNAME and SERIAL)*
* **Trace DNS delegation:**
```bash
dig +trace pension.isdb.org

```


* **Compare known-good application:**
```bash
dig @<NS1> matchmaking.isdb.org A
dig @<NS2> matchmaking.isdb.org A

```


* **Bypass DNS and test WAF:**
```bash
curl -vk --resolve pension.isdb.org:443:20.196.5.33 https://pension.isdb.org/

```



---

## 16. How to read the most important dig outcomes

* 🟢 **Healthy authoritative answer**
```text
status: NOERROR
flags: qr aa
ANSWER: pension.isdb.org. A 20.196.5.33

```


*Meaning:* This authoritative DNS server knows the record and says it maps to `20.196.5.33`.
* 🔴 **Authoritative NXDOMAIN**
```text
status: NXDOMAIN
flags: qr aa
ANSWER: 0

```


*Meaning:* This authoritative DNS server says the hostname doesn't exist. This is a major finding.
* 🟡 **Resolver NXDOMAIN**
`dig @168.63.129.16 pension.isdb.org A` returns `NXDOMAIN`.
*Meaning:* The recursive resolver is currently giving you a negative answer. Now query the authoritative servers directly to determine why.
* 🟡 **NOERROR but no A record**
Don't immediately call this NXDOMAIN. A name can exist but have no A record. Check:
```bash
dig pension.isdb.org ANY

```


or individually:
```bash
dig pension.isdb.org A
dig pension.isdb.org AAAA
dig pension.isdb.org CNAME

```



---

## 17. The key evidence from our incident

1. pension sometimes resolves to `20.196.5.33`
2. Explicit A query sometimes returns `NXDOMAIN`
3. Query authoritative servers directly
4. GO servers → `NXDOMAIN`
5. ITC servers → `20.196.5.33`
6. Both answers have `AA` flag
7. Therefore both are authoritative answers
8. SOA serials are different
9. SOA MNAMEs are different
10. **Authoritative DNS infrastructure is inconsistent**

---

## 18. What to tell the DNS team

> `pension.isdb.org` has inconsistent authoritative DNS responses. `ns1.go.com.sa` and `ns2.go.com.sa` return authoritative `NXDOMAIN`, while `ns1.itc.net.sa` and `ns2.itc.net.sa` return `A 20.196.5.33`. The SOA records also differ: GO uses MNAME `ns1.go.com.sa` with serial `2026041542`, while ITC uses MNAME `ns1.itc.net.sa` with serial `1580`. `matchmaking.isdb.org` resolves to `20.196.5.33` on all tested servers. Please verify the `isdb.org` NS delegation, DNS zone ownership/migration, and synchronization between GO and ITC DNS, and ensure all authoritative servers provide the intended record for `pension.isdb.org`.

---

## 19. Golden rules to remember

* `NXDOMAIN` = DNS says the name doesn't exist.
* `AA` = The DNS server is authoritative for that answer.
* Don't confuse `168.63.129.16` with an authoritative DNS server; it's the Azure DNS resolver path.
* Always query authoritative servers directly when investigating DNS problems.
* If authoritative servers disagree, you've found a DNS consistency problem.
* Compare a broken hostname with a working hostname using the same infrastructure.
* Compare SOA `MNAME` and `SERIAL` to detect different zone versions/architectures.
* DNS failure happens before FortiWeb and SharePoint.
* Use `curl --resolve` to bypass DNS and isolate DNS from WAF/application problems.
* For intermittent DNS problems, think about multiple authoritative servers + inconsistent records + DNS caching.

**The one-line mental model:**

```text
DNS → "Where is the application?"
      ↓
20.196.5.33 → FortiWeb
      ↓
FortiWeb → "Which backend?"
      ↓
SharePoint → "Process the request"

```

If the first question fails with `NXDOMAIN`, don't debug the last two layers yet.
