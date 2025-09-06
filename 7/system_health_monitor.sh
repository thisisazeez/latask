#!/bin/bash

LOG_FILE="/var/log/sys_health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

CPU_USAGE=$(awk '{u=$2+$4; t=$2+$3+$4+$5;} END {printf "%.1f", (u/t)*100}' /proc/stat)

MEMORY_USAGE=$(awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{printf "%.1f", ((total-avail)/total)*100}' /proc/meminfo)

DISK_USAGE=$(df / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')


LOAD_AVG=$(cat /proc/loadavg | awk '{print $1}')

echo "[$TIMESTAMP] CPU: ${CPU_USAGE}% | Memory: ${MEMORY_USAGE}% | Disk: ${DISK_USAGE}% | Load: ${LOAD_AVG}" >> "$LOG_FILE"
EOF