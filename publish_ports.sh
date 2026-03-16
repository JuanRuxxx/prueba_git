#!/bin/bash

set -e

pkill -f "socat TCP-LISTEN:8080" 2>/dev/null || true
pkill -f "socat TCP-LISTEN:8000" 2>/dev/null || true

WSL_IP=$(ip -4 addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)

VM1_IP=$(vagrant ssh vm1 -c "ip -4 addr show eth0 | awk '/inet / {print \$2}' | cut -d/ -f1 | head -n 1" 2>/dev/null | tr -d '\r' | tail -n 1)
VM2_IP=$(vagrant ssh vm2 -c "ip -4 addr show eth0 | awk '/inet / {print \$2}' | cut -d/ -f1 | head -n 1" 2>/dev/null | tr -d '\r' | tail -n 1)

if [ -z "$WSL_IP" ] || [ -z "$VM1_IP" ] || [ -z "$VM2_IP" ]; then
  echo "Error: no se pudieron obtener todas las IPs necesarias."
  echo "WSL_IP=$WSL_IP"
  echo "VM1_IP=$VM1_IP"
  echo "VM2_IP=$VM2_IP"
  exit 1
fi

nohup socat TCP-LISTEN:8080,bind=127.0.0.1,fork,reuseaddr TCP:${VM1_IP}:80 >/tmp/socat-vm1-localhost.log 2>&1 &
nohup socat TCP-LISTEN:8080,bind=${WSL_IP},fork,reuseaddr TCP:${VM1_IP}:80 >/tmp/socat-vm1-ip.log 2>&1 &

nohup socat TCP-LISTEN:8000,bind=127.0.0.1,fork,reuseaddr TCP:${VM2_IP}:8000 >/tmp/socat-vm2-localhost.log 2>&1 &
nohup socat TCP-LISTEN:8000,bind=${WSL_IP},fork,reuseaddr TCP:${VM2_IP}:8000 >/tmp/socat-vm2-ip.log 2>&1 &

echo "VM1 publicada en:"
echo "  http://localhost:8080"
echo "  http://${WSL_IP}:8080  -> ${VM1_IP}:80"

echo "VM2 publicada en:"
echo "  http://localhost:8000"
echo "  http://${WSL_IP}:8000  -> ${VM2_IP}:8000"
