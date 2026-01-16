#!/bin/bash
# Linux Resource Monitor - Shell Script Version
# A high-performance alternative using native Linux commands
# Provides similar functionality to the Python version without dependencies

set -e

# Configuration - Default refresh interval
REFRESH_INTERVAL=3.0
MODE="process"  # process or user
SORT_BY="cpu"   # cpu or mem

# Parse command line arguments
show_help() {
    cat << EOF
Linux Resource Monitor - Shell Script Version

Usage: $0 [OPTIONS]

Options:
    -r SECONDS    Set refresh interval in seconds (default: 3.0)
    -h            Show this help message

Examples:
    $0              # Use default 3 second refresh
    $0 -r 5         # Use 5 second refresh interval
EOF
}

while getopts "r:h" opt; do
    case $opt in
        r)
            REFRESH_INTERVAL="$OPTARG"
            # Validate it's a number
            if ! [[ "$REFRESH_INTERVAL" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Error: Refresh interval must be a number" >&2
                exit 1
            fi
            # Check minimum value using awk (no bc dependency)
            is_too_small=$(awk -v val="$REFRESH_INTERVAL" 'BEGIN { print (val < 0.5) ? 1 : 0 }')
            if [ "$is_too_small" -eq 1 ]; then
                echo "Error: Refresh interval must be at least 0.5 seconds" >&2
                exit 1
            fi
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# Terminal colors (ANSI codes)
BOLD='\033[1m'
RESET='\033[0m'

# Function to get system uptime
get_uptime() {
    awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime
}

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
}

# Function to get memory usage
get_memory_usage() {
    free | grep Mem | awk '{printf "%.1f%% (%.1fGB/%.1fGB)", $3/$2 * 100.0, $3/1024/1024, $2/1024/1024}'
}

# Function to get memory percentage only
get_memory_percent() {
    free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
}

# Function to display header
display_header() {
    local uptime=$(get_uptime)
    local cpu=$(get_cpu_usage)
    local mem=$(get_memory_usage)
    local datetime=$(date '+%Y-%m-%d %H:%M:%S')
    local width=$(tput cols)
    
    echo "Linux Resource Monitor - $datetime"
    echo "Uptime: $uptime | CPU: $cpu% | Memory: $mem"
    printf '%*s\n' "$width" | tr ' ' '-'
    
    if [ "$MODE" = "process" ]; then
        echo "Mode: PROCESS | Sort: $(echo $SORT_BY | tr '[:lower:]' '[:upper:]') | Refresh: ${REFRESH_INTERVAL}s"
    else
        echo "Mode: USER | Sort: $(echo $SORT_BY | tr '[:lower:]' '[:upper:]') | Refresh: ${REFRESH_INTERVAL}s"
    fi
    echo "[p]Process [c]CPU [q]Quit"
    printf '%*s\n' "$width" | tr ' ' '-'
}

# Function to parse and format process line
format_process_line() {
    local line="$1"
    local user=$(echo $line | awk '{print $1}')
    local pid=$(echo $line | awk '{print $2}')
    local cpu=$(echo $line | awk '{print $3}')
    local mem=$(echo $line | awk '{print $4}')
    local cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
    
    # Truncate command if too long
    if [ ${#cmd} -gt 48 ]; then
        cmd="${cmd:0:48}"
    fi
    
    printf "%-8s %-12s %-8s %-8s %-50s\n" "$pid" "$user" "$cpu" "$mem" "$cmd"
}

# Function to display process view
display_process_view() {
    local width=$(tput cols)
    
    # Print header
    printf "${BOLD}%-8s %-12s %-8s %-8s %-50s${RESET}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
    printf '%*s\n' "$width" | tr ' ' '-'
    
    # Sort by CPU or Memory
    if [ "$SORT_BY" = "cpu" ]; then
        ps aux --sort=-%cpu | head -n 11 | tail -n 10 | while read line; do
            format_process_line "$line"
        done
    else
        ps aux --sort=-%mem | head -n 11 | tail -n 10 | while read line; do
            format_process_line "$line"
        done
    fi
}

# Function to aggregate user stats
aggregate_user_stats() {
    ps aux | tail -n +2 | awk '{
        user[$1]++;
        cpu[$1]+=$3;
        mem[$1]+=$4;
    } END {
        for (u in user) {
            printf "%s %d %.1f %.1f\n", u, user[u], cpu[u], mem[u];
        }
    }'
}

# Function to display user aggregated view
display_user_view() {
    local width=$(tput cols)
    
    # Print header
    printf "${BOLD}%-16s %-12s %-12s %-12s${RESET}\n" "USER" "PROCESSES" "TOTAL CPU%" "TOTAL MEM%"
    printf '%*s\n' "$width" | tr ' ' '-'
    
    # Aggregate by user and sort
    if [ "$SORT_BY" = "cpu" ]; then
        aggregate_user_stats | sort -k3 -rn | head -n 15 | while read user procs cpu mem; do
            printf "%-16s %-12s %-12s %-12s\n" "$user" "$procs" "$cpu" "$mem"
        done
    else
        aggregate_user_stats | sort -k4 -rn | head -n 15 | while read user procs cpu mem; do
            printf "%-16s %-12s %-12s %-12s\n" "$user" "$procs" "$cpu" "$mem"
        done
    fi
}

# Function to handle keyboard input
handle_input() {
    # Use shorter timeout for more responsive input
    read -t 0.01 -n 1 key 2>/dev/null
    
    case "$key" in
        q|Q)
            return 1
            ;;
        p|P)
            # Toggle between process and user mode
            if [ "$MODE" = "process" ]; then
                MODE="user"
            else
                MODE="process"
            fi
            ;;
        c|C)
            # Toggle between cpu and mem sort
            if [ "$SORT_BY" = "cpu" ]; then
                SORT_BY="mem"
            else
                SORT_BY="cpu"
            fi
            ;;
    esac
    return 0
}

# Main loop
main() {
    # Hide cursor
    tput civis
    
    # Trap to restore cursor on exit
    trap 'tput cnorm; exit' INT TERM EXIT
    
    while true; do
        # Clear screen
        clear
        
        # Display header
        display_header
        
        # Display appropriate view
        if [ "$MODE" = "process" ]; then
            display_process_view
        else
            display_user_view
        fi
        
        # Handle input
        if ! handle_input; then
            break
        fi
        
        # Wait before refresh
        sleep $REFRESH_INTERVAL
    done
    
    # Restore cursor
    tput cnorm
    echo "Exiting..."
}

# Check if running with appropriate permissions
if [ ! -r /proc/uptime ]; then
    echo "Error: Cannot read /proc/uptime. Please check permissions."
    exit 1
fi

# Run main loop
main
