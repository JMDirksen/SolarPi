#!/bin/bash
cd "$(dirname "$0")"

# Check config file
[[ -f solarpi.conf ]] && . solarpi.conf || . solarpi.template.conf

# Current time
now=$(date "+%H%M")
now=${now#0}

# Get weather data
[[ "$1" = "-u" || ! -f weather_data.json ]] && {
  echo "$now Getting weather data for $weather_api_location"
  curl -s -o weather_data.json $weather_api_url
}

# Get/set sun up/down + convert to number
su=$(cat weather_data.json | jq -r ".liveweer[0].sup")
su=${su//:/}
su=${su#0}
sd=$(cat weather_data.json | jq -r ".liveweer[0].sunder")
sd=${sd//:/}
sd=${sd#0}

# Setup GPIO pin
raspi-gpio set $gpio_pin op  # Setup GPIO pin as Output
raspi-gpio set $gpio_pin dh  # Set GPIO pin High (switch = off)

# Check if sun up is after time on
[[ $su -gt $time_on ]] && {
  [[ $now -eq $time_on ]] && raspi-gpio set $gpio_pin dl  # Switch on @ time on
  [[ $now -eq $su ]] && raspi-gpio set $gpio_pin dh       # Switch off @ sun up
}

# Check if sun down is before time off
[[ $sd -lt $time_off ]] && {
  [[ $now -eq $sd ]] && raspi-gpio set $gpio_pin dl        # Switch on @ sun down
  [[ $now -eq $time_off ]] && raspi-gpio set $gpio_pin dh  # Switch off @ time off
}
