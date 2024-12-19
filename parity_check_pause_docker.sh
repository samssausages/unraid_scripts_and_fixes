#!/bin/bash

# Define an array of Docker containers to manage, can add our remove as needed
containers_to_manage=(
                    "deluge"
                    "sabnzbd"
                    )

# Variable to control auto-resuming of containers, optins are true or false.
auto_resume=true

###########################No need to edit below this line###########################
#####################################################################################

# Fetch the mdResyncPos variable value to determine if parity check is running, removing quotes
parityCheckStatus=$(cat /var/local/emhttp/var.ini | grep mdResyncPos | cut -d "=" -f2 | tr -d '"')

echo "Checking parity check status..."

# Check if a parity check is in progress
if [[ "$parityCheckStatus" != "0" ]]; then
    echo "Parity check is in progress. Pausing containers..."
    # Loop through the array and pause each container
    for container in "${containers_to_manage[@]}"; do
        # Check if container is running
        container_status=$(docker inspect --format '{{.State.Status}}' "$container" 2>/dev/null)
        if [[ "$container_status" == "running" ]]; then
            docker pause "$container"
            echo "$container paused."
        else
            echo "Cannot pause $container: It is $container_status or does not exist."
        fi
    done
elif [[ "$auto_resume" == true ]]; then
    echo "No parity check in progress. Checking for containers to unpause..."
    # Loop through the array and unpause each container
    for container in "${containers_to_manage[@]}"; do
        # Check if container is paused
        container_status=$(docker inspect --format '{{.State.Status}}' "$container" 2>/dev/null)
        if [[ "$container_status" == "paused" ]]; then
            docker unpause "$container"
            echo "$container unpaused."
        else
            echo "Cannot unpause $container: It is $container_status or does not exist."
        fi
    done
else
    echo "Auto-resume is disabled. Containers will remain paused."
fi
