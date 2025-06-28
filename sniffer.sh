#!/usr/bin/env bash
set -euo pipefail

# Directory locale dove salvare i .pcap
CAPTURE_DIR="$HOME/tulip/captures"
mkdir -p "$CAPTURE_DIR"

# Controlla che sshpass sia installato
if ! command -v sshpass &> /dev/null; then
  echo "Errore: sshpass non trovato. Installa con 'brew install hudochenkov/sshpass/sshpass' (macOS) o 'apt-get install sshpass' (Linux)."
  exit 1
fi

echo "Avvio sniffing continuo su $VM_IP (interfaccia: game). Ctrl+C per terminare."
while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  OUTFILE="$CAPTURE_DIR/capture_${TIMESTAMP}.pcap"

  # Esegue tshark sul server remoto e redirige l’output pcap in locale
  sshpass -p "$SSH_PASSWORD" \
    ssh -o BatchMode=no -o StrictHostKeyChecking=no \
        "$SSH_USER@$VM_IP" \
    "tshark -i game -a duration:10 -w -" \
    > "$OUTFILE"

  echo "  → Salvato: $OUTFILE"
done