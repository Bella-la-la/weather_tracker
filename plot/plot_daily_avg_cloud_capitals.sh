#!/bin/bash

MYSQL="/opt/lampp/bin/mysql -u root"

# Output folders
TXT_DIR="avg_cloud_capitals/txts"
PLOT_DIR="avg_cloud_capitals/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE="${TXT_DIR}/daily_avg_cloud_capitals.dat"
PLOTFILE="${PLOT_DIR}/daily_avg_cloud_capitals.png"

# Capital cities
CITIES=(
"Paris"
"Ottawa"
"Canberra"
"Tokyo"
)

# 1) Write header
{
    printf "Day"
    for CITY in "${CITIES[@]}"; do
        printf "\t%s" "$CITY"
    done
    printf "\n"
} > "$DATAFILE"

# 2) Generate daily average cloud cover
$MYSQL -N -e "
USE weather_db;

SELECT d.day,
       (SELECT AVG(cloudcover) FROM weather_data WHERE city='Paris'    AND DATE(date_time)=d.day),
       (SELECT AVG(cloudcover) FROM weather_data WHERE city='Ottawa'   AND DATE(date_time)=d.day),
       (SELECT AVG(cloudcover) FROM weather_data WHERE city='Canberra' AND DATE(date_time)=d.day),
       (SELECT AVG(cloudcover) FROM weather_data WHERE city='Tokyo'    AND DATE(date_time)=d.day)
FROM (
    SELECT DISTINCT DATE(date_time) AS day
    FROM weather_data
    WHERE DATE(date_time) <> '2025-11-08'
) AS d
ORDER BY d.day;
" >> "$DATAFILE"

# 3) Plot with gnuplot
gnuplot <<EOF
set terminal pngcairo size 1500,800
set output "$PLOTFILE"

set title "Daily Average Cloud Cover for World Capitals"
set xlabel "Day"

set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%m"
set autoscale xfix

set ylabel "Cloud Cover (%)"
set grid

set datafile separator "\t"
set datafile missing "NaN"
set key autotitle columnhead

plot for [i=2:5] "$DATAFILE" using 1:i every ::1 with lines lw 2 title columnheader(i)
EOF

echo "Plot saved as $PLOTFILE"
echo "Data saved as $DATAFILE"
