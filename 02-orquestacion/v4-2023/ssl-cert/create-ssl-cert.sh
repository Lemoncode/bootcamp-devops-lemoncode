#!/bin/bash
openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=k8s.lemoncoder.com/C=ES/L=Barcelona" \
            -keyout rootCA.key -out rootCA.crt 

# Create server pkey

openssl genrsa -out server.key 2048

# Create CSR

openssl req -new -key server.key -out server.csr -config csr.conf

# Create CERT

openssl x509 -req \
    -in server.csr \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out server.crt \
    -days 365 \
    -sha256 -extfile cert.conf