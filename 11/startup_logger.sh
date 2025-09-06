#!/bin/bash

LOG_FILE="/var/log/startup_info.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== Boot: $TIMESTAMP ===" >> "$LOG_FILE"
echo "Hostname: $(hostname)" >> "$LOG_FILE"
echo "Uptime: $(cat /proc/uptime | cut -d' ' -f1) seconds" >> "$LOG_FILE"
echo "Load: $(cat /proc/loadavg | cut -d' ' -f1)" >> "$LOG_FILE"
echo "Memory Total: $(awk '/MemTotal/ {print $2 $3}' /proc/meminfo)" >> "$LOG_FILE"
echo "Disk Root: $(df / | tail -1 | awk '{print $5}')" >> "$LOG_FILE"
echo "Script completed successfully" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

logger "startup logger completed"