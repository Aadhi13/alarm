#!/bin/bash

alarm() {
    # Optional: Handle "alarm" as a subcommand prefix
    if [[ $1 == "alarm" ]]; then
        shift
    fi

    local time_arg=""
    local countdown_arg=""
    local description="Time's up!.."
    local mode=""
    local music="/usr/share/sounds/alsa/Front_Center.wav"

    # Helper to convert human-readable time (e.g., "2h30m", "5m", "300") to seconds
    time_to_seconds() {
        local input="$1"
        local total=0
        
        # Extract hours (e.g., "2h" -> 7200)
        if [[ $input =~ ([0-9]+)h ]]; then
            total=$((total + ${BASH_REMATCH[1]} * 3600))
            input="${input/${BASH_REMATCH[0]}/}"  # Remove matched part
        fi
        
        # Extract minutes (e.g., "30m" -> 1800)
        if [[ $input =~ ([0-9]+)m ]]; then
            total=$((total + ${BASH_REMATCH[1]} * 60))
            input="${input/${BASH_REMATCH[0]}/}"  # Remove matched part
        fi
        
        # Extract seconds (e.g., "45s" -> 45), or assume whole input is seconds if no units
        if [[ $input =~ ([0-9]+)s ]]; then
            total=$((total + ${BASH_REMATCH[1]}))
        elif [[ $input =~ ^[0-9]+$ ]]; then
            total=$((total + input))  # Plain number = seconds
        fi
        
        echo "$total"
    }
   
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            t|-t)
                mode="time"
                time_arg="$2"
                shift 2
                ;;
            c|-c)
                mode="countdown"
                countdown_arg="$2"
                shift 2
                ;;
            d|-d)
                description="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
   
    # Calculate sleep duration
    local sleep_duration=0
   
    if [[ "$mode" == "time" ]]; then
        # Parse target time (HH:MM format)
        local target_time="$time_arg"
        local current_epoch=$(date +%s)
        local target_epoch=$(date -d "$target_time" +%s)
       
        # If target time is earlier than current time, assume it's for tomorrow
        if [[ $target_epoch -le $current_epoch ]]; then
            target_epoch=$(date -d "tomorrow $target_time" +%s)
        fi
       
        #sleep_duration=$((target_epoch - current_epoch))
	sleep_duration=$(time_to_seconds "$countdown_arg") 
       
    elif [[ "$mode" == "countdown" ]]; then
        sleep_duration="$countdown_arg"
    else
        echo "Usage: alarm {t|-t} HH:MM [{d|-d} \"description\"]"
        echo "       alarm {c|-c} SECONDS [{d|-d} \"description\"]"
	echo "Usage: alarm {t|-t} HH:MM [{d|-d} \"description\"]"
        echo "       alarm {c|-c} TIME [{d|-d} \"description\"]"
        echo "jTIME: seconds (e.g., 300), minutes (e.g., 5m), hours (e.g., 2h), or mixed (e.g., 1h30m)"
        return 1
    fi
   
    # Execute the alarm command
    sleep "$sleep_duration" && notify-send "Alarm" "$description" && aplay "$music" &
   
    echo "Alarm set for $sleep_duration seconds"
}

# Call the function with script arguments (supports both sourced and executed modes)
alarm "$@"
