#!/bin/bash
#server health report script Part 1 - Disk and Memory

echo "=== Health Report For $(hostname) at $(date '+%F %H:%M:%S') ==="

check_disk() {
 local path="$1"
 local limit="$2"
 local usage
  usage=$(df -h "$path" | awk 'NR==2 {print $5}' | tr -d '%')
  echo "Amount of disk used for $path: ${usage}%"
 if [ "$usage" -ge "$limit" ]; then
  return 1
 else
  return 0
 fi
}

check_memory() {
 local available_limit="$1"
 local available
  available=$(free -m | awk 'NR==2 {print $7}')
  echo "Memory available is ${available}Mb"
 if [ "$available" -ge "$available_limit" ]; then
  return 0
 else
  return 1
 fi
}

check_cpu() {
 local limit="$1"
 local cpu_load
  cpu_load=$(awk -v cores="$(nproc)" '{printf "%d", $1/cores*100}' /proc/loadavg)
  echo "Load on CPU is ${cpu_load}% of its capacity"
 if [ "$cpu_load" -ge "$limit" ]; then
  return 1
 else
  return 0
 fi
}

check_service() {
 local name="$1"
 if systemctl is-active --quiet "$name"; then
  echo "$name is active and running"
  return 0
 else
  echo "$name is not running"
  return 1
 fi
}

status=0
check_disk / 80 || status=1
check_memory 1000 || status=1
check_cpu 80 || status=1
check_service nginx || status=1

if [ "$status" -eq 0 ]; then
 echo "Result: ALL CHECKS PASSED, NO PROBLEMS FOUND" 
else
 echo "Result: PROBLEM FOUND, CHECK NEEDED"
fi
exit $status
