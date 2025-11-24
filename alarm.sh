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
       
        sleep_duration=$((target_epoch - current_epoch))
       
    elif [[ "$mode" == "countdown" ]]; then
        sleep_duration="$countdown_arg"
    else
        echo "Usage: alarm {t|-t} HH:MM [{d|-d} \"description\"]"
        echo "       alarm {c|-c} SECONDS [{d|-d} \"description\"]"
        return 1
    fi
   
    # Execute the alarm command
    sleep "$sleep_duration" && notify-send "Alarm" "$description" && aplay "$music" &
   
    echo "Alarm set for $sleep_duration seconds"
}

# Call the function with script arguments (supports both sourced and executed modes)
alarm "$@"
