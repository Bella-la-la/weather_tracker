CITY="$1"
if [ -z "$CITY" ]; then
    echo "Usage: ./plot_heat_index_vs_humidity_city.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"

TXT_DIR="heat_index_vs_humidity_city/txts"
PLOT_DIR="heat_index_vs_humidity_city/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE="${TXT_DIR}/${CITY}_heatindex_vs_humidity.dat"
PLOTFILE="${PLOT_DIR}/${CITY}_heatindex_vs_humidity.png"

echo -e "Day\tAvgHumidity\tAvgHeatIndexEffect" > "$DATAFILE"

$MYSQL -N -e "
USE weather_db;

SELECT 
    DATE(date_time) AS day,
    AVG(relative_humidity) AS avg_humidity,
    AVG(apparent_temperature - temperature) AS avg_heat_index_effect
FROM weather_data
WHERE city='$CITY' AND DATE(date_time) <> '2025-11-08'
GROUP BY DATE(date_time)
ORDER BY day;
" >> "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1400,800
set output "$PLOTFILE"
set title "Heat Index Effect vs Humidity (Daily Averages) for $CITY"
set xlabel "Average Humidity (%)"
set ylabel "Average Heat Index Effect (°C)"
set grid
set datafile separator "\t"
plot "$DATAFILE" using 2:3 with points pointtype 7 pointsize 1.8 lc rgb "red" title "$CITY"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
