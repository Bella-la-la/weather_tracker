CITY="$1"

if [ -z "$CITY" ]; then
    echo "Usage: ./plot_minmax.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"

TXT_DIR="min_max/txts"
PLOT_DIR="min_max/plots"

mkdir -p "$TXT_DIR"
mkdir -p "$PLOT_DIR"

DATAFILE="${TXT_DIR}/${CITY}_minmax.dat"
PLOTFILE="${PLOT_DIR}/${CITY}_minmax.png"

$MYSQL -e "
USE weather_db;
SELECT DATE(date_time) AS day,
       MIN(temperature) AS min_temp,
       MAX(temperature) AS max_temp
FROM weather_data
WHERE city='$CITY'
GROUP BY DATE(date_time)
ORDER BY day;
" | sed '1d' > "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1200,600
set output "$PLOTFILE"
set title "Daily Temperature Range for $CITY"
set xlabel "Date"
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%m"
set ylabel "Temperature (°C)"
set grid
plot "$DATAFILE" using 1:2 with lines lw 2 linecolor "blue" title "Min Temp", \
     "$DATAFILE" using 1:3 with lines lw 2 linecolor "red" title "Max Temp"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
