from bottle import route, run, redirect
from os import system

@route('/')
def index():
  header = '<html><head><meta name="viewport" content="width=device-width, initial-scale=3.0"><title>SolarPi</title></head><body bgcolor="black">'
  buttonOn = '<button onClick="location.href=\'/on\'" style="color:white; background-color:green">On</button>'
  buttonOff = '<button onClick="location.href=\'/off\'" style="color:white; background-color:red">Off</button>'
  footer = '</body></html>'
  buttons = header + buttonOn + ' ' + buttonOff + footer
  return buttons

@route('/on')
def on():
  print('Switch on!')
  system('./solarpi.sh -on')
  redirect('/')
  return

@route('/off')
def off():
  print('Switch off!')
  system('./solarpi.sh -off')
  redirect('/')
  return

run(host='0.0.0.0', port=8080)
