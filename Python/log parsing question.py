## Python Log Parsing Challenge

 You’re given a web server log file where each line looks like this:

```
2026-09-22 10:15:32 INFO GET /api/users 200 124ms
2026-09-22 10:15:35 ERROR GET /api/users 500 842ms
2026-09-22 10:16:01 INFO POST /api/login 200 231ms
2026-09-22 10:16:08 WARN GET /api/products 429 105ms
2026-09-22 10:17:44 ERROR GET /api/orders 503 1204ms
2026-09-22 10:18:02 INFO GET /api/users 200 98ms
2026-09-22 10:18:15 ERROR POST /api/login 401 67ms
```

 ### Your task

 Write a Python function:

```
def analyze_logs(log_file):
    ...
```

 It should read the log file and return a dictionary containing:

 1. The **total number of requests**.
2. The number of requests for each HTTP status code.
3. The number of `ERROR` log entries.
4. The **average response time** in milliseconds.
5. The endpoint with the **highest average response time**.
6. A list of all requests that took **more than 500 ms**, containing:
   - timestamp
   - HTTP method
   - endpoint
   - status code
   - response time

 For the sample above, your result should be approximately:

```
{
    "total_requests": 7,
    "status_codes": {
        200: 3,
        500: 1,
        429: 1,
        503: 1,
        401: 1
    },
    "error_count": 3,
    "average_response_ms": 381.57,
    "slowest_endpoint": "/api/orders",
    "slow_requests": [
        {
            "timestamp": "2026-09-22 10:15:35",
            "method": "GET",
            "endpoint": "/api/users",
            "status": 500,
            "response_ms": 842
        },
        {
            "timestamp": "2026-09-22 10:17:44",
            "method": "GET",
            "endpoint": "/api/orders",
            "status": 503,
            "response_ms": 1204
        }
    ]
}
```

 **Bonus:** Handle malformed log lines without crashing and report how many lines were skipped.
