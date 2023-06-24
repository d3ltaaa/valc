#!/bin/bash

mkdir -p /home/falk/Documents/battery_test

percent="$(cat /sys/class/power_supply/BAT0/capacity)"
date="$(date)"
echo "Name of the file? " 
read name
echo "Comment: "
read comment
echo ${comment} > /home/falk/Documents/battery_test/${name}.txt

echo "${percent}% : ${date}"
echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt


while [ "$percent" -ge 1 ]
do
    percent="$(cat /sys/class/power_supply/BAT0/capacity)"
    date="$(date)"
    
    if [ "$percent" -eq 100 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 90 ]; then
        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 80 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 70 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi
    if [ "$percent" -eq 60 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 50 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi
    if [ "$percent" -eq 40 ]; then


        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi
    if [ "$percent" -eq 30 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 20 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    if [ "$percent" -eq 10 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi


    if [ "$percent" -eq 1 ]; then

        echo "${percent}% : ${date}"
        echo "${percent}% : ${date}" >> /home/falk/Documents/battery_test/${name}.txt
        sleep 300
    fi

    sleep 10

done
    # if [ "$percent" -ge 70 ] && [ "$percent" -lt 90 ]; then
    #     echo "${percent}% : ${date}"
    #     echo "${percent}% : ${date}" >> /home/falk/${name}.txt
    #
    # elif [ "$percent" -ge 40 ] && [ "$percent" -lt 70 ]; then
    #
    #     echo "${percent}% : ${date}"
    #     echo "${percent}% : ${date}" >> /home/falk/${name}.txt
    #
    # elif [ "$percent" -ge 20 ] && [ "$percent" -lt 40 ]; then
    #
    #     echo "${percent}% : ${date}"
    #     echo "${percent}% : ${date}" >> /home/falk/${name}.txt
    #
    # elif [ "$percent" -ge 0 ] && [ "$percent" -lt 20 ]; then
    #
    #     echo "${percent}% : ${date}"
    #     echo "${percent}% : ${date}" >> /home/falk/${name}.txt
    # fi



