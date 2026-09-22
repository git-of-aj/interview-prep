services = [
    {"service_name": "auth", "status": 200, "response_time_ms": 120},
    {"service_name": "auth", "status": 200, "response_time_ms": 105},
    {"service_name": "auth", "status": 200, "response_time_ms": 135},
    {"service_name": "auth", "status": 403, "response_time_ms": 95},
    {"service_name": "auth", "status": 403, "response_time_ms": 110},
    {"service_name": "auth", "status": 500, "response_time_ms": 350},
    {"service_name": "auth", "status": 401, "response_time_ms": 85},
    {"service_name": "auth", "status": 200, "response_time_ms": 125},

    {"service_name": "payments", "status": 200, "response_time_ms": 210},
    {"service_name": "payments", "status": 200, "response_time_ms": 195},
    {"service_name": "payments", "status": 200, "response_time_ms": 225},
    {"service_name": "payments", "status": 403, "response_time_ms": 115},
    {"service_name": "payments", "status": 403, "response_time_ms": 125},
    {"service_name": "payments", "status": 500, "response_time_ms": 480},
    {"service_name": "payments", "status": 502, "response_time_ms": 520},
    {"service_name": "payments", "status": 201, "response_time_ms": 240},

    {"service_name": "orders", "status": 200, "response_time_ms": 175},
    {"service_name": "orders", "status": 200, "response_time_ms": 160},
    {"service_name": "orders", "status": 200, "response_time_ms": 190},
    {"service_name": "orders", "status": 403, "response_time_ms": 105},
    {"service_name": "orders", "status": 403, "response_time_ms": 120},
    {"service_name": "orders", "status": 404, "response_time_ms": 130},
    {"service_name": "orders", "status": 500, "response_time_ms": 410},
    {"service_name": "orders", "status": 201, "response_time_ms": 180},

    {"service_name": "inventory", "status": 200, "response_time_ms": 145},
    {"service_name": "inventory", "status": 200, "response_time_ms": 155},
    {"service_name": "inventory", "status": 200, "response_time_ms": 140},
    {"service_name": "inventory", "status": 403, "response_time_ms": 100},
    {"service_name": "inventory", "status": 403, "response_time_ms": 115},
    {"service_name": "inventory", "status": 503, "response_time_ms": 620},
    {"service_name": "inventory", "status": 500, "response_time_ms": 450},
    {"service_name": "inventory", "status": 200, "response_time_ms": 165},

    {"service_name": "auth", "status": 200, "response_time_ms": 118},
    {"service_name": "payments", "status": 403, "response_time_ms": 108},
    {"service_name": "orders", "status": 200, "response_time_ms": 172},
    {"service_name": "inventory", "status": 200, "response_time_ms": 152},
    {"service_name": "auth", "status": 403, "response_time_ms": 102},
    {"service_name": "payments", "status": 200, "response_time_ms": 205},
    {"service_name": "orders", "status": 403, "response_time_ms": 118},
    {"service_name": "inventory", "status": 200, "response_time_ms": 148},
]

### = PRO: 
# or better 
unique_services = {item['service_name'] for item in services} # set

for svc in unique_services:
    response_times = []

    for item in services:
        if item['service_name'] == svc and item['status'] == 200:
            response_times.append(item['response_time_ms'])

    average = sum(response_times) / len(response_times)

    print(f"Average response time for {svc}: {average:.2f} ms")

### =========== NAIVE ==========

list_of_auth = []
list_of_inventory = []
list_of_orders = []
list_of_payments = []

for item in services:
    if item['status'] == 200:
        if item['service_name'] == 'auth':
            list_of_auth.append(item['response_time_ms'])

        elif item['service_name'] == 'inventory':
            list_of_inventory.append(item['response_time_ms'])

        elif item['service_name'] == 'orders':
            list_of_orders.append(item['response_time_ms'])

        elif item['service_name'] == 'payments':
            list_of_payments.append(item['response_time_ms'])


print("auth:", list_of_auth)
print("inventory:", list_of_inventory)
print("orders:", list_of_orders)
print("payments:", list_of_payments)

print("Average auth:", sum(list_of_auth) / len(list_of_auth))
print("Average inventory:", sum(list_of_inventory) / len(list_of_inventory))
print("Average orders:", sum(list_of_orders) / len(list_of_orders))
print("Average payments:", sum(list_of_payments) / len(list_of_payments))
