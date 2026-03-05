#!/bin/bash
# // Konfigurasi Bot Global
# File ini berfungsi sebagai pusat notifikasi
export KEY="8226263150:AAFdiVuQeEshxOpSvema_F6fDwbyFcfNWnw"
export CHATID="6577966386"

# // Fungsi Kirim Log Otomatis
# Digunakan dengan cara: send_log "ISI PESAN"
send_log() {
    local PESAN="$1"
    curl -s -X POST "https://api.telegram.org/bot$KEY/sendMessage" \
        -d chat_id="$CHATID" \
        -d text="$PESAN" \
        -d parse_mode="HTML" > /dev/null
}

