# Requirements
    apt install jq

# Crontab
    SHELL=/bin/bash
    * * * * * ~/solarpi/solarpi.sh >> ~/solarpi/solarpi.log 2>&1
