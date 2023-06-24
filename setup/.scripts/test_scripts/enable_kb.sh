#!/bin/bash
check_status () {
    
    status_kb=$(xinput list-props 12 | grep "Device Enabled" | awk '{print $4}')
    if [[ $status_kb = 1 ]]; then 
        echo yes
    elif [[ $status_kb = 0 ]]; then
        echo no
    fi
}
xinput disable 12
check_status
sleep 5
xinput enable 12
check_status

