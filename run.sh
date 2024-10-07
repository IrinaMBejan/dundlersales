#!/bin/bash

# Welcome to the run.sh tutorial!
# This script solves the challenge of managing multiple tasks that need to run
# at different intervals within a SyftBox application.

# Problem: How do we keep track of when each task was last run?
# Solution: Create a directory to store timestamps for each section
TIMESTAMP_DIR="./script_timestamps"
mkdir -p "$TIMESTAMP_DIR"
mkdir -p "state"

# Problem: How do we determine if enough time has passed to run a task again?
# Solution: Create a function to check the time difference
function should_run() {
    local section=$1
    local interval=$2
    local timestamp_file="$TIMESTAMP_DIR/${section}_last_run"

    if [ ! -f "$timestamp_file" ]; then
        return 0
    fi

    last_run=$(cat "$timestamp_file")
    current_time=$(date +%s)
    time_diff=$((current_time - last_run))

    if [ $time_diff -ge $interval ]; then
        return 0
    else
        return 1
    fi
}

# Problem: How do we ensure our project always has the latest dependencies?
# Solution: Create a function to update dependencies using 'uv'
function update_dependencies() {
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv venv .venv
    uv pip install -r requirements.txt
}

# Problem: How do we record when a task was last run?
# Solution: Create a function to update the timestamp for a section
function update_timestamp() {
    local section=$1
    local timestamp_file="$TIMESTAMP_DIR/${section}_last_run"
    date +%s > "$timestamp_file"
}

# Problem: How do we handle tasks that should run every 5 minutes?
# Solution: Create a function for 5-minute interval tasks
function section() {
    local section="EXAMPLE PROJECT: section_1"
    local interval=300  # 5 minutes

    if should_run "$section" $interval; then
        echo "Running $section..."
        uv run python main_5_mins.py
        echo "Section 1 completed."
        update_timestamp "$section"
    else
        echo "Skipping $section, not enough time has passed."
    fi
}

update_dependencies
section
