# Requirements
    apt install jq

# Crontab
    @reboot   bash -cl ~/solarpi/solarpi.sh -s >> ~/solarpi/solarpi.log 2>&1
    0 3 * * * bash -cl ~/solarpi/solarpi.sh -u >> ~/solarpi/solarpi.log 2>&1
    * * * * * bash -cl ~/solarpi/solarpi.sh    >> ~/solarpi/solarpi.log 2>&1
