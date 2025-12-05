#!/bin/bash

LOGDIR="/home/devin1/weather-tracker/logs"
MYSQL="/opt/lampp/bin/mysql -u root"

# Loop through all log files
for file in $LOGDIR/collect_log_*.txt; do
    echo "Processing $file"

    while IFS= read -r line; do

        # detect start of a city block
        if [[ "$line" == getting\ data\ for* ]]; then
            city=$(echo "$line" | awk '{print $4}')
        fi

        [[ "$line" == temp:* ]] && temp=$(echo "$line" | awk '{print $2}')
        [[ "$line" == "feel like:"* ]] && feel=$(echo "$line" | awk '{print $3}')
        [[ "$line" == humidity:* ]] && hum=$(echo "$line" | awk '{print $2}')
        [[ "$line" == pressure:* ]] && pres=$(echo "$line" | awk '{print $2}')
        [[ "$line" == "wind speed:"* ]] && wind=$(echo "$line" | awk '{print $3}')
        [[ "$line" == "wind direction:"* ]] && winddir=$(echo "$line" | awk '{print $3}')
        [[ "$line" == rain:* ]] && rain=$(echo "$line" | awk '{print $2}')
        [[ "$line" == cloud:* ]] && cloud=$(echo "$line" | awk '{print $2}')
        [[ "$line" == radiation:* ]] && rad=$(echo "$line" | awk '{print $2}')
        [[ "$line" == "UV index:"* ]] && uv=$(echo "$line" | awk '{print $3}')
        [[ "$line" == "dew point:"* ]] && dew=$(echo "$line" | awk '{print $3}')
        [[ "$line" == "weather code:"* ]] && code=$(echo "$line" | awk '{print $3}')

        if [[ "$line" == "data collected at:"* ]]; then
            dt=$(echo "$line" | awk '{print $4 " " $5}')
        fi

        # when the block ends, insert into DB
        if [[ "$line" == done\ for* ]]; then

            # check if exists
            count=$($MYSQL -e "USE weather_db; SELECT COUNT(*) FROM weather_data WHERE city='$city' AND date_time='$dt';" | tail -n 1)

            if [[ "$count" -eq 0 ]]; then
                $MYSQL -e "
                USE weather_db;
                INSERT INTO weather_data (
                    city, date_time, temperature, windspeed, apparent_temperature,
                    relative_humidity, surface_pressure, winddirection, precipitation,
                    cloudcover, shortwave_radiation, uv_index, dew_point, weather_code
                )
                VALUES (
                    '$city', '$dt', '$temp', '$wind', '$feel',
                    '$hum', '$pres', '$winddir', '$rain',
                    '$cloud', '$rad', '$uv', '$dew', '$code'
                );
                "
                echo "Inserted: $city $dt"
            else
                echo "Skipped (already exists): $city $dt"
            fi

        fi

    done < "$file"

done
