
DIR="$(cd "$(dirname "$0")" && pwd)"
LOGDIR="$DIR/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/collect_log_$(date +'%Y%m%d_%H%M').txt"

echo "WEATHER DATA COLLECTION" | tee -a "$LOGFILE"

cities=("Kuala_Lumpur" "George_Town" "Kota_Kinabalu" "Kuching" "Johor_Bahru" "Ipoh" "Melaka" "Alor_Setar" "Paris" "Ottawa" "Canberra" "Tokyo")

declare -A coords
coords["Kuala_Lumpur"]="3.139,101.6869"
coords["George_Town"]="5.4141,100.3288"
coords["Kota_Kinabalu"]="5.9804,116.0735"
coords["Kuching"]="1.5533,110.3592"
coords["Johor_Bahru"]="1.4927,103.7414"
coords["Ipoh"]="4.5975,101.0901"
coords["Melaka"]="2.1896,102.2501"
coords["Alor_Setar"]="6.1210,100.3600"
coords["Paris"]="48.8566,2.3522"
coords["Ottawa"]="45.4215,-75.6992"
coords["Canberra"]="-35.2809,149.1300"
coords["Tokyo"]="35.6895,139.6917"

for city in "${cities[@]}"
do
  echo "-" | tee -a "$LOGFILE"
  if [[ "$city" == "Kuala_Lumpur" ]]; then
    echo "MALAYSIA CITIES" | tee -a "$LOGFILE"
  elif [[ "$city" == "Paris" ]]; then
    echo "WORLD CAPITALS" | tee -a "$LOGFILE"
  fi

  echo "getting data for $city" | tee -a "$LOGFILE"

  c=${coords[$city]}
  lat=${c%,*}
  lon=${c#*,}

  curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,surface_pressure,windspeed_10m,winddirection_10m,precipitation,cloudcover,shortwave_radiation,uv_index,dew_point_2m,weathercode&timezone=UTC" > "$DIR/data.json"

  now_utc=$(date -u +"%Y-%m-%dT%H:00")
  idx=$(jq -r --arg t "$now_utc" '.hourly.time | index($t)' "$DIR/data.json")
  [ "$idx" = "null" ] || [ -z "$idx" ] && idx=0


  temp=$(jq ".hourly.temperature_2m[$idx]" "$DIR/data.json")
  feel=$(jq ".hourly.apparent_temperature[$idx]" "$DIR/data.json")
  hum=$(jq ".hourly.relative_humidity_2m[$idx]" "$DIR/data.json")
  pres=$(jq ".hourly.surface_pressure[$idx]" "$DIR/data.json")
  wind=$(jq ".hourly.windspeed_10m[$idx]" "$DIR/data.json")
  winddir=$(jq ".hourly.winddirection_10m[$idx]" "$DIR/data.json")
  rain=$(jq ".hourly.precipitation[$idx]" "$DIR/data.json")
  cloud=$(jq ".hourly.cloudcover[$idx]" "$DIR/data.json")
  sun=$(jq ".hourly.shortwave_radiation[$idx]" "$DIR/data.json")
  uv=$(jq ".hourly.uv_index[$idx]" "$DIR/data.json")
  dew=$(jq ".hourly.dew_point_2m[$idx]" "$DIR/data.json")
  code=$(jq ".hourly.weathercode[$idx]" "$DIR/data.json")

  {
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
    echo "weather code: $code"
  } | tee -a "$LOGFILE"

  time_now=$(date +"%Y-%m-%d %H:%M:%S")
  "$DIR/save_to_db.sh" "$city" "$time_now" "$temp" "$wind" "$feel" "$hum" "$pres" "$winddir" "$rain" "$cloud" "$sun" "$uv" "$dew" "$code"

  echo "data collected at: $time_now" | tee -a "$LOGFILE"
  echo "done for $city" | tee -a "$LOGFILE"
done

echo " ALL CITIES DONE" | tee -a "$LOGFILE"
