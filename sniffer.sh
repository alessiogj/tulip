#!/usr/bin/env bash
set -euo pipefail

# Carica variabili da .env
set -a
[ -f .env ] && source .env
set +a

# Controlla che tutte le variabili siano settate
if [ -z "${SSH_USER:-}" ] || [ -z "${SSH_PASSWORD:-}" ] || [ -z "${VM_IP:-}" ]; then
  echo "Errore: Assicurati che SSH_USER, SSH_PASSWORD e VM_IP siano definiti nel file .env."
  exit 1
fi

# Directory locale dove salvare i .pcap
mkdir -p "$TRAFFIC_DIR_HOST"

# Controlla che sshpass sia installato
if ! command -v sshpass &> /dev/null; then
  echo "Errore: sshpass non trovato. Installa con 'brew install hudochenkov/sshpass/sshpass' (macOS) o 'apt-get install sshpass' (Linux)."
  exit 1
fi

echo "Avvio sniffing continuo su $VM_IP (interfaccia: game). Ctrl+C per terminare."
while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  OUTFILE="$TRAFFIC_DIR_HOST/capture_${TIMESTAMP}.pcap"

  # Esegue tshark sul server remoto e redirige l'output pcap in locale
  sshpass -p "$SSH_PASSWORD" \
    ssh -o BatchMode=no -o StrictHostKeyChecking=no \
        "$SSH_USER@$VM_IP" \
    "tshark -i $INTERFACE -a duration:10 -w -" \
    > "$OUTFILE"

  echo "  → Salvato: $OUTFILE"
done