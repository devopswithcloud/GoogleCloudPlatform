#!/usr/bin/env bash
set -euo pipefail

# Generates a private key, CSR, and a self-signed certificate for the domain.
DOMAIN="prod.i27academy.in"
DAYS=365
OUT_DIR="./certs"

mkdir -p "$OUT_DIR"

# 1. Private key
openssl genrsa -out "$OUT_DIR/${DOMAIN}.key" 2048

# 2. Certificate Signing Request (CSR) - use this if getting the cert signed by a CA (e.g. Let's Encrypt, DigiCert)
openssl req -new \
  -key "$OUT_DIR/${DOMAIN}.key" \
  -out "$OUT_DIR/${DOMAIN}.csr" \
  -subj "/C=IN/ST=Telangana/L=Hyderabad/O=i27 Academy/OU=IT/CN=${DOMAIN}"

# 3. Self-signed certificate (use this for local/dev/staging; skip if using the CSR with a real CA)
openssl x509 -req \
  -in "$OUT_DIR/${DOMAIN}.csr" \
  -signkey "$OUT_DIR/${DOMAIN}.key" \
  -out "$OUT_DIR/${DOMAIN}.crt" \
  -days "$DAYS" \
  -extfile <(printf "subjectAltName=DNS:%s" "$DOMAIN")

echo "Key:  $OUT_DIR/${DOMAIN}.key"
echo "CSR:  $OUT_DIR/${DOMAIN}.csr"
echo "Cert: $OUT_DIR/${DOMAIN}.crt"
