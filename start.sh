#!/bin/bash

# VM Connection Details
VM_IP="10.60.39.1"
VM_USER="root"
VM_PASSWORD="JKULBXoRKw833qSH"

# Local capture directory
LOCAL_CAPTURE_DIR="captures"

# Create local capture directory if it doesn't exist
mkdir -p "$LOCAL_CAPTURE_DIR"

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null
then
    echo "sshpass is not installed. Please install it to continue (e.g., sudo apt-get install sshpass or brew install http://git.io/sshpass.rb)."
    exit 1
fi

echo "Connecting to VM $VM_USER@$VM_IP to set up tshark and capture..."

# Install tshark on the VM and create capture directory
sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_IP" "\
    apt-get update && apt-get install -y tshark && \
    mkdir -p /captures && \
    echo 'tshark installed and /captures directory created.'
"

# Start tshark on the VM in the background, capturing to /captures folder
sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_IP" "\
    nohup bash -c '\
        while true; do \
            tshark -i game -w /captures/capture_\\$(date +%Y%m%d_\\%H\\%M\\%S).pcap -a duration:10 -b filesize:100000 -b files:1000 &> /dev/null & \
            sleep 10 \
        done \
    ' > /dev/null 2>&1 &"

echo "tshark is now running on $VM_IP, capturing to /captures on the VM."
echo "You can find the captured files on the VM at /captures."

# You can also use scp to copy files from the VM to your local machine (optional)
# For example, to copy files every 30 seconds:
# while true; do
#     sshpass -p "$VM_PASSWORD" scp -o StrictHostKeyChecking=no "$VM_USER@$VM_IP:/captures/*.pcap" "$LOCAL_CAPTURE_DIR/"
#     sleep 30
# done

