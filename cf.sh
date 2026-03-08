#!/bin/bash

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        AUTO DOMAIN SETUP   "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Install dependency jika belum ada
apt update -y
apt install -y jq curl

# Ambil IP VPS
IP=$(curl -s ifconfig.me)

# Input domain dari user
read -rp "Masukkan Domain Anda : " DOMAIN

# Subdomain (bisa sama dengan domain utama)
SUB_DOMAIN="$DOMAIN"

# Cloudflare API
CF_ID="ajijainalganteng@gmail.com"
CF_KEY=""

echo ""
echo "IP VPS  : $IP"
echo "Domain  : $SUB_DOMAIN"
echo ""
sleep 2

echo "Updating DNS Cloudflare..."

# Ambil Zone ID Cloudflare
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
-H "X-Auth-Email: ${CF_ID}" \
-H "X-Auth-Key: ${CF_KEY}" \
-H "Content-Type: application/json" | jq -r '.result[0].id')

# Ambil DNS Record jika sudah ada
RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
-H "X-Auth-Email: ${CF_ID}" \
-H "X-Auth-Key: ${CF_KEY}" \
-H "Content-Type: application/json" | jq -r '.result[0].id')

# Jika record belum ada maka buat record baru
if [[ "${#RECORD}" -le 10 ]]; then
    RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{
        "type":"A",
        "name":"'"${SUB_DOMAIN}"'",
        "content":"'"${IP}"'",
        "ttl":120,
        "proxied":false
    }' | jq -r '.result.id')
fi

# Update DNS record
RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
-H "X-Auth-Email: ${CF_ID}" \
-H "X-Auth-Key: ${CF_KEY}" \
-H "Content-Type: application/json" \
--data '{
    "type":"A",
    "name":"'"${SUB_DOMAIN}"'",
    "content":"'"${IP}"'",
    "ttl":120,
    "proxied":false
}')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Domain berhasil ditambahkan"
echo "Host : $SUB_DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Simpan domain
mkdir -p /var/lib/scrz-prem
mkdir -p /etc/xray

echo "$SUB_DOMAIN" > /root/domain
echo "IP=$SUB_DOMAIN" > /var/lib/scrz-prem/ipvps.conf

# Copy domain ke xray
cp /root/domain /etc/xray/domain

echo ""
echo "Setup selesai."
sleep 2
