#!/usr/bin/python3

import RPi.GPIO as GPIO
import time
import datetime
import json, requests

import config as c

def main():
  switch1 = 37  #  BCM 26  WiringPi P25
  switch2 = 38  #  BCM 20  WiringPi P28
  switch3 = 40  #  BCM 21  WiringPi P29
  switchOn = GPIO.LOW
  switchOff = GPIO.HIGH
  GPIO.setmode(GPIO.BOARD)
  GPIO.setup(switch1, GPIO.OUT)
  GPIO.setup(switch2, GPIO.OUT)
  GPIO.setup(switch3, GPIO.OUT)
  GPIO.output(switch1, GPIO.HIGH)
  GPIO.output(switch2, GPIO.HIGH)
  GPIO.output(switch3, GPIO.HIGH)
  sun_rise = sun_set = False

  try:
    while True:
      cur_time = datetime.datetime.now().hour * 100 + datetime.datetime.now().minute
      
      if not sun_rise or cur_time == 0:
        sun_rise, sun_set = get_sun_times()
        print(cur_time, "Got sun rise/set: ", sun_rise, sun_set)
      
      if c.allowed_on_between[0] <= cur_time <= c.allowed_on_between[1] and ( cur_time >= sun_set or cur_time <= sun_rise ):
        if GPIO.input(switch1) == switchOff:
          print(cur_time, "Switching on")
          GPIO.output(switch1, switchOn)
      else:
        if GPIO.input(switch1) == switchOn:
          print(cur_time, "Switching off")
          GPIO.output(switch1, switchOff)

      time.sleep(59)
  
  except KeyboardInterrupt:
    pass
  
  finally:
    GPIO.cleanup()


def get_sun_times():
  weerlive_api = "https://weerlive.nl/api/json-data-10min.php?key=" + c.weerlive_api_key + "&locatie=" + c.weerlive_location
  data = json.loads(requests.get(weerlive_api).text)
  return int(data['liveweer'][0]['sup'].replace(":","")), int(data['liveweer'][0]['sunder'].replace(":",""))


if __name__ == "__main__":
  main()
