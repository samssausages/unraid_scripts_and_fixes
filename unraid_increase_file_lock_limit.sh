#!/bin/bash

# Unraid default ulimit is 40k open files.  Upon reaching this limit all unraid shares will dissapear.  This script will increase the ulimit.  Run on a cron shedule, every 5 minutes should be good.
# You may need to reduce the polling time, if you still find yourself hitting the limit with a 5 min polling duration.

# Set unlim -n to 1048576
ulimit -n 1048576

# Function to set ulimit -n for child processes
function set_ulimit_for_children() {
  local parent_pid=$1
  local limit=$2

  # Get the list of child PIDs from pstree output
  local child_pids=$(pstree -p $parent_pid | grep -oE '[0-9]+')

  # Iterate over the child PIDs and set ulimit -n for each child process
  for child_pid in $child_pids; do
    # Skip the parent PID
    if [ "$child_pid" != "$parent_pid" ]; then
      echo "Increasing ulimit -n for PID $child_pid"
      prlimit --pid $child_pid --nofile=$limit
    fi
  done
}

# Set the desired ulimit -n value
limit=1048576  # A million is a lot of open files

# Get PIDs for any instances of "/usr/local/bin/shfs"
parent_pids=$(pgrep -f "/usr/local/bin/shfs")

# Iterate over all instances of "/usr/local/bin/shfs"
for parent_pid in $parent_pids; do
  # Check if the parent process exists
  if ! kill -0 $parent_pid > /dev/null 2>&1; then
    echo "No running /usr/local/bin/shfs process found with PID $parent_pid."
    exit 1
  fi

  # Set ulimit -n for the parent process
  echo "Increasing ulimit -n for PID $parent_pid"
  prlimit --pid $parent_pid --nofile=$limit

  # Call the function to set ulimit -n for child processes
  set_ulimit_for_children $parent_pid $limit
done
