CITY="$1"
if [ -z "$CITY" ]; then
    echo "Usage: ./plot_cloud_vs_radiation_city.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"


TXT_DIR="cloud_vs_radiation_city/txts"
PLOT_DIR="cloud_vs_radiation_city/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE="${TXT_DIR}/${CITY}_cloud_vs_radiation.dat"
PLOTFILE="${PLOT_DIR}/${CITY}_cloud_vs_radiation.png"


echo -e "Day\tAvgCloud\tAvgRadiation" > "$DATAFILE"


$MYSQL -N -e "
USE weather_db;

SELECT 
    DATE(date_time) AS day,
    AVG(cloudcover) AS avg_cloud,
    AVG(shortwave_radiation) AS avg_radiation
FROM weather_data
WHERE city='$CITY' AND DATE(date_time) <> '2025-11-08'
GROUP BY DATE(date_time)
ORDER BY day;
" >> "$DATAFILE"


gnuplot <<EOF
set terminal pngcairo size 1400,800
set output "$PLOTFILE"
set title "Cloudiness vs Radiation (Daily Averages) for $CITY"
set xlabel "Average Cloud Cover (%)"
set ylabel "Average Radiation (W/m²)"
set grid
set datafile separator "\t"

plot "$DATAFILE" using 2:3 with points pointtype 7 pointsize 1.8 lc rgb "blue" title "$CITY"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
