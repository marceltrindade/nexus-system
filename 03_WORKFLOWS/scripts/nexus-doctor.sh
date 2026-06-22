#!/bin/bash

# Nexus Health Check Script (v1.1) - Corrected Dir Check

# Nodes to Ping
NODES=("{{TAILSCALE_IP_VALIS}}:VALIS" "{{TAILSCALE_IP_PRIS}}:PRIS" "{{TAILSCALE_IP_UBIK}}:UBIK" "{{LAN_IP_ROY}}:ROY")

echo "--- 🛰️ Nexus Mesh Connectivity ---"
for entry in "${NODES[@]}"; do
    IP=${entry%:*}
    NAME=${entry##*:}
    if ping -c 1 -W 1 $IP > /dev/null; then
        echo "✅ $NAME ($IP) is ONLINE"
    else
        echo "❌ $NAME ($IP) is OFFLINE"
    fi
done

# Check Mounts and Critical Dirs on UBIK
echo -e "
--- 🗄️ UBIK Storage Validation ---"
if mountpoint -q "/mnt/almox"; then
    echo "✅ /mnt/almox (HDD 1TB) is MOUNTED"
else
    echo "❌ /mnt/almox (HDD 1TB) is MISSING"
fi

if [ -d "/home/{{LINUX_USER}}/Projects/Nexus-Docs" ]; then
    echo "✅ Nexus-Docs Directory is PRESENT"
else
    echo "❌ Nexus-Docs Directory is MISSING"
fi

# Check Key Services via NC
echo -e "
--- ⚙️ Critical Services Status ---"
SERVICES=("{{TAILSCALE_IP_VALIS}}:222:Forgejo-SSH" "{{TAILSCALE_IP_VALIS}}:3000:Forgejo-Web" "{{TAILSCALE_IP_PRIS}}:8096:Jellyfin (legado)")
for s in "${SERVICES[@]}"; do
    IP=$(echo $s | cut -d: -f1)
    PORT=$(echo $s | cut -d: -f2)
    NAME=$(echo $s | cut -d: -f3)
    if nc -z -w 1 $IP $PORT; then
        echo "✅ $NAME is REACHABLE"
    else
        echo "❌ $NAME is UNREACHABLE"
    fi
done
