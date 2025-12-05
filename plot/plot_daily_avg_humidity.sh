
CITY="$1"

if [ -z "$CITY" ]; then
    echo "Usage: ./plot_daily_avg_humidity.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"


TXT_DIR="avg_humidity/txts"
PLOT_DIR="avg_humidity/plots"


mkdir -p "$TXT_DIR"
mkdir -p "$PLOT_DIR"


DATAFILE="${TXT_DIR}/${CITY}_avg_humidity.dat"
PLOTFILE="${PLOT_DIR}/${CITY}_avg_humidity.png"


$MYSQL -e "
USE weather_db;
SELECT DATE(date_time) AS day,
       AVG(relative_humidity) AS avg_humidity
FROM weather_data
WHERE city='$CITY'
GROUP BY DATE(date_time)
ORDER BY day;
" | sed '1d' > "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1200,600
set output "$PLOTFILE"

set title "Daily Average Humidity for $CITY"
set xlabel "Date"
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%m"

set ylabel "Humidity (%)"
set grid
set yrange [0:100]

plot "$DATAFILE" using 1:2 with lines lw 2 linecolor "blue" title "Average Humidity"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
