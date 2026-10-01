#!/bin/bash

URL="http://4.224.114.213"
SUCCESS=0
UNSUCCESSFUL=0

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    HTTP_CODE=$(curl -sS -o /dev/null \
        --connect-timeout 5 \
        --max-time 10 \
        -w "%{http_code}" \
        "$URL" 2>/dev/null)

    if [ "$HTTP_CODE" = "200" ]; then
        ((SUCCESS++))
    else
        ((UNSUCCESSFUL++))
        echo "Unsuccessful request timestamp: $TIMESTAMP | HTTP Status: ${HTTP_CODE:-CURL_ERROR}"
    fi

    echo -ne "\rSuccess Count: $SUCCESS | Unsuccessful Count: $UNSUCCESSFUL"

    sleep 1
done
