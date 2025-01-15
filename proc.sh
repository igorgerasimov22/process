#!/bin/bash

printf "%-6s %-9s %-5s %-8s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

HZ=$(getconf CLK_TCK)

for pid in /proc/[0-9]*; do
    pid=${pid##*/}

    if [[ -r /proc/$pid/stat ]]; then
        stat=$(< /proc/$pid/stat)

        tty_nr=$(echo "$stat" | awk '{print $7}')
        utime=$(echo "$stat" | awk '{print $14}')
        stime=$(echo "$stat" | awk '{print $15}')
        state=$(echo "$stat" | awk '{print $3}')

        total_time=$((utime + stime))
        time=$(printf "%02d:%02d:%02d" $((total_time / HZ / 3600)) $((total_time / HZ % 3600 / 60)) $((total_time / HZ % 60)))

        if [[ $tty_nr -eq 0 ]]; then
            tty="?"
        else
            tty=$(ls -l /dev | awk -v nr=$tty_nr '$6 * 256 + $7 == nr {print $10}')
            tty=${tty:-"?"}
        fi

        cmdline=$(< /proc/$pid/cmdline)
        if [[ -z $cmdline ]]; then
            cmdline="[$(awk '{print $2}' /proc/$pid/stat | tr -d '()')]"
        else
            cmdline=$(echo "$cmdline" | tr '\0' ' ')
        fi

        printf "%-6s %-9s %-5s %-8s %s\n" "$pid" "$tty" "$state" "$time" "$cmdline"
    fi
done
