#!/bin/bash

urls=(
  "https://www.vssps.visualstudio.com"
  "https://www.vsblob.visualstudio.com"
  "https://login.microsoftonline.com"
  "https://dev.azure.com"
  "https://aex.dev.azure.com"
  "https://www.management.core.windows.net"
  "https://management.core.windows.net"

)

echo "Starting HTTPS reachability check..."
for url in "${urls[@]}"; do
  echo -n "Checking $url... "
  if curl --head --silent --connect-timeout 5 "$url" | grep -q "HTTP"; then
    echo "✅ Reachable"
  else
    echo "❌ Not reachable"
  fi
done
