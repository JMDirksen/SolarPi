#!/bin/bash
cd "$(dirname "$0")"

# Load config file
[[ -f solarpi.conf ]] && . solarpi.conf || . solarpi.template.conf

# Current time
now=$(date "+%H%M")  # Get time formatted as number
now=$((10#$now))     # Convert string to base 10 number

# Get GPIO pin state
pin_state=$(raspi-gpio get $gpio_pin)  # Get command output
pin_state=${pin_state// /}             # Remove spaces
pin_state=(${pin_state//func=/ })      # Replace func= with a space and convert to array
pin_state=${pin_state[1]}              # Get 2nd array element (= state)

# Setup GPIO pin
[[ "$pin_state" != "OUTPUT" ]] && {
  echo "$now Setting up GPIO pin $gpio_pin"
  raspi-gpio set $gpio_pin op  # Setup GPIO pin as Output
  raspi-gpio set $gpio_pin dh  # Set GPIO pin High (switch = off)
}

# Parameter switch on/off
[[ "$1" = "-on"  ]] && raspi-gpio set $gpio_pin dl && echo "$now Switch on (manual)"
[[ "$1" = "-off" ]] && raspi-gpio set $gpio_pin dh && echo "$now Switch off (manual)"

# Get weather data (on: time, parameter, missing file)
[[ $now -eq $time_update_weather || "$1" = "-u" || ! -f weather_data.json ]] && {
  echo "$now Getting weather data for $weather_api_location"
  curl -s -o weather_data.json $weather_api_url
}

# Get/set sun up/down + convert to number
su=$(cat weather_data.json | jq -r ".liveweer[0].sup")
su=$((10#${su//:/}))  # Remove semicolon and leading zeros
sd=$(cat weather_data.json | jq -r ".liveweer[0].sunder")
sd=$((10#${sd//:/}))  # Remove semicolon and leading zeros

# Switch on/off
[[ $su -gt $time_on ]] && {            # Sun up after time on
  [[ $now -eq $time_on ]] && {         # @ time on
    echo "$now Switch on (time on)"
    raspi-gpio set $gpio_pin dl        # Switch on
  }
  [[ $now -eq $su ]] && {              # @ sun up
    echo "$now Switch off (sun up)"
    raspi-gpio set $gpio_pin dh        # Switch off
  }
}

[[ $sd -lt $time_off ]] && {           # Sun down before time off
  [[ $now -eq $sd ]] && {              # @ sun down
    echo "$now Switch on (sun down)"
    raspi-gpio set $gpio_pin dl        # Switch on
  }
  [[ $now -eq $time_off ]] && {        # @ time off
    echo "$now Switch off (time off)"
    raspi-gpio set $gpio_pin dh        # Switch off
  }
}
