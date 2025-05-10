#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found."
    exit 1
fi

request_counts() {
    echo "=== Request Statistics ==="
    TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")
    echo "Total Requests: $TOTAL_REQUESTS"
    GET_REQUESTS=$(grep '"GET' "$LOG_FILE" | wc -l)
    echo "GET Requests: $GET_REQUESTS"
    POST_REQUESTS=$(grep '"POST' "$LOG_FILE" | wc -l)
    echo "POST Requests: $POST_REQUESTS"
    echo ""
}

unique_ips() {
    echo "=== Unique IP Addresses ==="
    UNIQUE_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq | wc -l)
    echo "Total Unique IPs: $UNIQUE_IPS"
    echo "GET and POST requests per IP:"
    awk '{print $1}' "$LOG_FILE" | sort | uniq | while read -r IP; do
        IP_GET=$(grep "$IP" "$LOG_FILE" | grep '"GET' | wc -l)
        IP_POST=$(grep "$IP" "$LOG_FILE" | grep '"POST' | wc -l)
        echo "IP: $IP, GET: $IP_GET, POST: $IP_POST"
    done
    echo ""
}

failure_requests() {
    echo "=== Failed Requests ==="
    FAILED_REQUESTS=$(awk '$9 ~ /^[45][0-9][0-9]$/ {count++} END {print count+0}' "$LOG_FILE")
    echo "Failed Requests (4xx/5xx): $FAILED_REQUESTS"
    if [ "$TOTAL_REQUESTS" -gt 0 ]; then
        FAILURE_PERCENT=$(echo "scale=2; ($FAILED_REQUESTS / $TOTAL_REQUESTS) * 100" | bc)
        echo "Failure Rate: $FAILURE_PERCENT%"
    else
        echo "Failure Rate: 0%"
    fi
    echo ""
}

top_user() {
    echo "=== Top Active User ==="
    TOP_IP=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    TOP_COUNT=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    echo "Most Active IP: $TOP_IP with $TOP_COUNT requests"
    echo ""
}

daily_request_averages() {
    echo "=== Daily Request Average ==="
    DAYS=$(awk -F'[:[]' '{print $2}' "$LOG_FILE" | cut -d'/' -f1,2,3 | sort | uniq | wc -l)
    if [ "$DAYS" -gt 0 ]; then
        AVG_REQUESTS=$(echo "scale=2; $TOTAL_REQUESTS / $DAYS" | bc)
        echo "Average Requests per Day: $AVG_REQUESTS"
    else
        echo "Average Requests per Day: 0"
    fi
    echo ""
}

failure_analysis() {
    echo "=== Failure Analysis by Day ==="
    echo "Top 3 Days with Failures:"
    awk '$9 ~ /^[45][0-9][0-9]$/ {print $4}' "$LOG_FILE" | cut -d'[' -f2 | cut -d':' -f1 | sort | uniq -c | sort -nr | head -3
    echo ""
}

requests_by_hour() {
    echo "=== Requests by Hour ==="
    awk -F'[:[]' '{print $3}' "$LOG_FILE" | cut -d':' -f1 | sort | uniq -c | sort -n
    echo ""
}

request_trends() {
    echo "=== Request Trends ==="
    PEAK_HOUR=$(awk -F'[:[]' '{print $3}' "$LOG_FILE" | cut -d':' -f1 | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    PEAK_COUNT=$(awk -F'[:[]' '{print $3}' "$LOG_FILE" | cut -d':' -f1 | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    echo "Peak Hour: $PEAK_HOUR with $PEAK_COUNT requests"
    echo "Trend: Higher activity during peak hour ($PEAK_HOUR)."
    echo ""
}

status_codes_breakdown() {
    echo "=== Status Code Breakdown ==="
    awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr
    echo ""
}

most_active_by_method() {
    echo "=== Most Active IP by Method ==="
    TOP_GET_IP=$(grep '"GET' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    TOP_GET_COUNT=$(grep '"GET' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    echo "Top GET IP: $TOP_GET_IP with $TOP_GET_COUNT requests"
    TOP_POST_IP=$(grep '"POST' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    TOP_POST_COUNT=$(grep '"POST' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    echo "Top POST IP: $TOP_POST_IP with $TOP_POST_COUNT requests"
    echo ""
}

failure_patterns() {
    echo "=== Failure Patterns ==="
    echo "Top 3 Hours with Failures:"
    awk '$9 ~ /^[45][0-9][0-9]$/ {print $4}' "$LOG_FILE" | cut -d'[' -f2 | cut -d':' -f2 | sort | uniq -c | sort -nr | head -3
    echo ""
}

request_counts
unique_ips
failure_requests
top_user
daily_request_averages
failure_analysis
requests_by_hour
request_trends
status_codes_breakdown
most_active_by_method
failure_patterns
