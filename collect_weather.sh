#!/bin/bash
# get weather for 12 cities (8 malaysia + 4 capitals)
# first malaysia cities then capitals

echo "==================== MALAYSIA CITIES ===================="

malaysia=("Kuala_Lumpur" "George_Town" "Kota_Kinabalu" "Kuching" "Johor_Bahru" "Ipoh" "Melaka" "Alor_Setar")
declare -A coords_m
coords_m["Kuala_Lumpur"]="3.139,101.6869"
coords_m["George_Town"]="5.4141,100.3288"
coords_m["Kota_Kinabalu"]="5.9804,116.0735"
coords_m["Kuching"]="1.5533,110.3592"
coords_m["Johor_Bahru"]="1.4927,103.7414"
coords_m["Ipoh"]="4.5975,101.0901"
coords_m["Melaka"]="2.1896,102.2501"
coords_m["Alor_Setar"]="6.1210,100.3600"

for city in "${malaysia[@]}"
do
  c=${coords_m[$city]}
  lat=${c%,*}
  lon=${c#*,}
  echo "------------------------------"
  echo "getting data for $city"
  curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,surface_pressure,windspeed_10m,winddirection_10m,precipitation,cloudcover,shortwave_radiation,uv_index,dew_point_2m&timezone=auto" > data.json

  temp=$(jq '.hourly.temperature_2m[0]' data.json)
  feel=$(jq '.hourly.apparent_temperature[0]' data.json)
  hum=$(jq '.hourly.relative_humidity_2m[0]' data.json)
  pres=$(jq '.hourly.surface_pressure[0]' data.json)
  wind=$(jq '.hourly.windspeed_10m[0]' data.json)
  winddir=$(jq '.hourly.winddirection_10m[0]' data.json)
  rain=$(jq '.hourly.precipitation[0]' data.json)
  cloud=$(jq '.hourly.cloudcover[0]' data.json)
  sun=$(jq '.hourly.shortwave_radiation[0]' data.json)
  uv=$(jq '.hourly.uv_index[0]' data.json)
  dew=$(jq '.hourly.dew_point_2m[0]' data.json)

  echo "temp: $temp °C"
  echo "feel like: $feel °C"
  echo "humidity: $hum %"
  echo "pressure: $pres hPa"
  echo "wind speed: $wind km/h"
  echo "wind direction: $winddir °"
  echo "rain: $rain mm"
  echo "cloud: $cloud %"
  echo "radiation: $sun W/m²"
  echo "UV index: $uv"
  echo "dew point: $dew °C"
  echo "done for $city"
done

echo "==================== WORLD CAPITALS ===================="

declare -A coords_c
coords_c["Paris"]="48.8566,2.3522"
coords_c["Ottawa"]="45.4215,-75.6992"
coords_c["Canberra"]="-35.2809,149.1300"
coords_c["Tokyo"]="35.6895,139.6917"

for city in "${!coords_c[@]}"
do
  c=${coords_c[$city]}
  lat=${c%,*}
  lon=${c#*,}
  echo "------------------------------"
  echo "getting data for $city"
  curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,surface_pressure,windspeed_10m,winddirection_10m,precipitation,cloudcover,shortwave_radiation,uv_index,dew_point_2m&timezone=auto" > data.json

  temp=$(jq '.hourly.temperature_2m[0]' data.json)
  feel=$(jq '.hourly.apparent_temperature[0]' data.json)
  hum=$(jq '.hourly.relative_humidity_2m[0]' data.json)
  pres=$(jq '.hourly.surface_pressure[0]' data.json)
  wind=$(jq '.hourly.windspeed_10m[0]' data.json)
  winddir=$(jq '.hourly.winddirection_10m[0]' data.json)
  rain=$(jq '.hourly.precipitation[0]' data.json)
  cloud=$(jq '.hourly.cloudcover[0]' data.json)
  sun=$(jq '.hourly.shortwave_radiation[0]' data.json)
  uv=$(jq '.hourly.uv_index[0]' data.json)
  dew=$(jq '.hourly.dew_point_2m[0]' data.json)

  echo "temp: $temp °C"
  echo "feel like: $feel °C"
  echo "humidity: $hum %"
  echo "pressure: $pres hPa"
  echo "wind speed: $wind km/h"
  echo "wind direction: $winddir °"
  echo "rain: $rain mm"
  echo "cloud: $cloud %"
  echo "radiation: $sun W/m²"
  echo "UV index: $uv"
  echo "dew point: $dew °C"
  echo "done for $city"
done
