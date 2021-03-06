#!/bin/bash
cd "$(dirname "$0")"

# Load config file
[[ -f solarpi.conf ]] && . solarpi.conf || . solarpi.template.conf

# Current time
now=$(date "+%H%M")  # Get time formatted as number
now=$((10#$now))     # Convert string to base 10 number

# Current date (for logging)
date=$(date "+%y%m%d")

# Get GPIO pin state
pin_get=($(raspi-gpio get $gpio_pin))  # Get command output as array
pin_state=${pin_get[4]}                # Get 5th array element
pin_state=${pin_state//func=/}         # Remove func=

# Setup GPIO pin
[[ "$pin_state" != "OUTPUT" ]] && {
  echo "$date $now Setting up GPIO pin $gpio_pin with state off"
  raspi-gpio set $gpio_pin op  # Setup GPIO pin as Output
  raspi-gpio set $gpio_pin dh  # Set GPIO pin High (switch = off)
  exit
}

# Get weather data (on: time, parameter, missing file)
[[ $now -eq $time_update_weather || "$1" = "-u" || ! -f weather_data.json ]] && {
  echo "$date $now Getting weather data for $weather_api_location"
  curl -s -o weather_data.json $weather_api_url
  [[ $(cat weather_data.json | jq -r ".liveweer[0].plaats") != $weather_api_location ]] && {
    echo "$date $now Error in weather data:"
    cat weather_data.json
    echo
    rm weather_data.json
    exit
  }
}

# Get/set sun up/down + convert to number
su=$(cat weather_data.json | jq -r ".liveweer[0].sup")
su=$((10#${su//:/}))  # Remove semicolon and leading zeros
sd=$(cat weather_data.json | jq -r ".liveweer[0].sunder")
sd=$((10#${sd//:/}))  # Remove semicolon and leading zeros

# Parameter switch on/off/state
[[ "$1" = "-on"  ]] && raspi-gpio set $gpio_pin dl && echo "$date $now Switch on (manual)" && exit
[[ "$1" = "-off" ]] && raspi-gpio set $gpio_pin dh && echo "$date $now Switch off (manual)" && exit
[[ "$1" = "-state" ]] && {
  switch_state=${pin_get[2]}             # Get 3rd array element
  switch_state=${switch_state//level=/}  # Remove level=
  [[ switch_state -eq 1 ]] && switch_state=Off || switch_state=On
  echo "$date $now Switch: $switch_state  Sun up/down: $su/$sd ($weather_api_location)"
  exit
}

# Switch on/off
[[ $su -gt $time_on ]] && {            # Sun up after time on
  [[ $now -eq $time_on ]] && {         # @ time on
    echo "$date $now Switch on (time on)"
    raspi-gpio set $gpio_pin dl        # Switch on
  }
  [[ $now -eq $su ]] && {              # @ sun up
    echo "$date $now Switch off (sun up)"
    raspi-gpio set $gpio_pin dh        # Switch off
  }
}

[[ $sd -lt $time_off ]] && {           # Sun down before time off
  [[ $now -eq $sd ]] && {              # @ sun down
    echo "$date $now Switch on (sun down)"
    raspi-gpio set $gpio_pin dl        # Switch on
  }
  [[ $now -eq $time_off ]] && {        # @ time off
    echo "$date $now Switch off (time off)"
    raspi-gpio set $gpio_pin dh        # Switch off
  }
}
