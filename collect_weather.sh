#!/bin/bash
# Fetch and print current temperature for four Malaysian cities

declare -A cities=(
  ["Kuala_Lumpur"]="3.139,101.6869"
  ["George_Town"]="5.4141,100.3288"
  ["Kota_Kinabalu"]="5.9804,116.0735"
  ["Kuching"]="1.5533,110.3592"
)

for city in "${!cities[@]}"; do
  coords=${cities[$city]}
  lat=${coords%,*}
  lon=${coords#*,}
  
  DATA=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true")
  TEMP=$(echo $DATA | jq '.current_weather.temperature')
  
  echo "Current temperature in $city: $TEMP°C"
done

