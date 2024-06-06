#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <URL> <number_of_requests>"
  exit 1
}

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  usage
fi

URL=$1
NUM_REQUESTS=$2
TOTAL_TIME=0
MIN_TIME=999999
MAX_TIME=0

# Check if the number of requests is a positive integer
if ! [[ $NUM_REQUESTS =~ ^[0-9]+$ ]] || [ $NUM_REQUESTS -le 0 ]; then
  echo "Error: number_of_requests must be a positive integer."
  exit 1
fi

# Loop to perform the requests, sum up the response times, and find min and max times
for ((i=1; i<=NUM_REQUESTS; i++))
do
  RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}\n" "$URL")
  TOTAL_TIME=$(echo "$TOTAL_TIME + $RESPONSE_TIME" | bc)

  # Update min and max response times
  if (( $(echo "$RESPONSE_TIME < $MIN_TIME" | bc -l) )); then
    MIN_TIME=$RESPONSE_TIME
  fi

  if (( $(echo "$RESPONSE_TIME > $MAX_TIME" | bc -l) )); then
    MAX_TIME=$RESPONSE_TIME
  fi

  sleep 2
done

# Calculate and display the average response time
AVERAGE_TIME=$(echo "scale=3; $TOTAL_TIME / $NUM_REQUESTS" | bc)
echo "Average response time: $AVERAGE_TIME seconds"
echo "Minimum response time: $MIN_TIME seconds"
echo "Maximum response time: $MAX_TIME seconds"
