services = {
    "auth": [
        {"service_name": "auth", "status": 200, "response_time_ms": 120},
        {"service_name": "auth", "status": 500, "response_time_ms": 350},
        {"service_name": "auth", "status": 200, "response_time_ms": 100},
        {"service_name": "auth", "status": 403, "response_time_ms": 80},
    ],
    "payment": [
        {"service_name": "payment", "status": 200, "response_time_ms": 450},
        {"service_name": "payment", "status": 500, "response_time_ms": 900},
        {"service_name": "payment", "status": 200, "response_time_ms": 500},
        {"service_name": "payment", "status": 302, "response_time_ms": 150},
    ],
    "order": [
        {"service_name": "order", "status": 200, "response_time_ms": 220},
        {"service_name": "order", "status": 200, "response_time_ms": 180},
        {"service_name": "order", "status": 500, "response_time_ms": 700},
        {"service_name": "order", "status": 200, "response_time_ms": 200},
    ],
    "inventory": [
        {"service_name": "inventory", "status": 200, "response_time_ms": 90},
        {"service_name": "inventory", "status": 403, "response_time_ms": 60},
        {"service_name": "inventory", "status": 200, "response_time_ms": 110},
        {"service_name": "inventory", "status": 500, "response_time_ms": 400},
    ],
}

#print(services.items())
for service_name, log in services.items():
    svc_response_time = 0
    success_count = 0

    for item in log:
        if item['status'] == 200:
            svc_response_time += item['response_time_ms']
            success_count += 1

    if success_count > 0:
        avg = svc_response_time / success_count
        print(f"Average time for {service_name} is: {avg} ms for number of HTTP 200: {success_count} ")

    #print(log)
    # service_names is list of keys - inventory, auth etc
    # log = list of values from each key like, the list gets updated one-by-one with values for each key: 
    # iter1: [{'service_name': 'auth', 'status': 200, 'response_time_ms': 120}, {'service_name': 'auth', 'status': 500, 'response_time_ms': 350}, {'service_name': 'auth', 'status': 200, 'response_time_ms': 100}, {'service_name': 'auth', 'status': 403, 'response_time_ms': 80}]
    