import sys
import time
import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient


def create_resource_group(rg_name):
    subscription_id = os.environ["AZURE_SUBSCRIPTION_ID","38e274f8-10b9-4348-bd1d-62d18e5458d1"]
    location = os.environ.get("AZURE_LOCATION", "eastus")

    credential = DefaultAzureCredential()

    client = ResourceManagementClient(
        credential,
        subscription_id
    )

    rg = client.resource_groups.create_or_update(
        rg_name,
        {
            "location": location
        }
    )

    print(f"Resource group created: {rg.name}")
    print(f"Location: {rg.location}")


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: python main.py <resource-group-name>")
        sys.exit(1)

    rg_name = sys.argv[1]

    create_resource_group(rg_name)

    print("Container is staying alive for workload identity testing...")

    while True:
        time.sleep(3600)