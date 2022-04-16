# Requirements
    apt install jq python3 python3-pip screen
    pip install bottle

# Crontab
    SHELL=/bin/bash
    @reboot cd ~/solarpi && screen -dmS solarpi python3 webinterface.py
    * * * * * ~/solarpi/solarpi.sh >> ~/solarpi/solarpi.log 2>&1
