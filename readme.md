# Requirements
    apt install jq

# Crontab
    SHELL=/bin/bash
    * * * * * ~/solarpi/solarpi.sh    >> ~/solarpi/solarpi.log 2>&1
    0 3 * * * ~/solarpi/solarpi.sh -u >> ~/solarpi/solarpi.log 2>&1
