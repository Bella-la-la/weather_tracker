#!/bin/bash
# save_to_db.sh
# save all weather data to mysql

city=$1
time_now=$2
temp=$3
wind=$4
feel=$5
hum=$6
pres=$7
winddir=$8
rain=$9
cloud=${10}
sun=${11}
uv=${12}
dew=${13}
code=${14}

/opt/lampp/bin/mysql -u root -e "
USE weather_db;
INSERT INTO weather_data (city, date_time, temperature, windspeed, weather_code, apparent_temperature, relative_humidity, surface_pressure, winddirection, precipitation, cloudcover, shortwave_radiation, uv_index, dew_point)
VALUES ('$city', '$time_now', '$temp', '$wind', '$code', '$feel', '$hum', '$pres', '$winddir', '$rain', '$cloud', '$sun', '$uv', '$dew');
"
