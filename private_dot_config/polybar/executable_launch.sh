#!/usr/bin/env bash

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 0.2
done

if command -v xrandr >/dev/null 2>&1; then
  while IFS= read -r monitor; do
    [ -n "$monitor" ] || continue
    MONITOR="$monitor" polybar --reload main >/tmp/polybar-"$monitor".log 2>&1 &
  done < <(xrandr --query | awk '/ connected/ {print $1}')
else
  polybar --reload main >/tmp/polybar.log 2>&1 &
fi
