#!/bin/bash

# Check if the input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File $input_file not found!"
    exit 1
fi

# Clear the output files if they exist
> ssl_hosts.txt
> no_ssl.txt

# Process each host:port in the input file
while IFS= read -r line || [[ -n "$line" ]]; do
    host_port=$(echo $line | tr -d ' ')
    host=${host_port%:*}
    port=${host_port#*:}

    # Run OpenSSL command with timeout and grep for BEGIN CERTIFICATE
    timeout 3 openssl s_client -connect ${host}:${port} </dev/null 2>/dev/null | grep -q "BEGIN CERTIFICATE"

    # Check the output and write to the respective file
    if [ $? -eq 0 ]; then
        echo "${host}:${port}" | tee -a ssl_hosts.txt
    else
        echo "${host}:${port}" >> no_ssl.txt
    fi
done < "$input_file"
