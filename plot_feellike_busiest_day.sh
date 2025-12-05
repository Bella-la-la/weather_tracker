CITY="$1"

if [ -z "$CITY" ]; then
    echo "Usage: ./plot_feellike_busiest_day.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"


TXT_DIR="feellike_busiest_day/txts"
PLOT_DIR="feellike_busiest_day/plots"

mkdir -p "$TXT_DIR"
mkdir -p "$PLOT_DIR"

BEST_DAY=$( $MYSQL -N -e "
USE weather_db;
SELECT DATE(date_time)
FROM weather_data
WHERE city='$CITY'
  AND DATE(date_time) <> '2025-11-08'
GROUP BY DATE(date_time)
ORDER BY COUNT(*) DESC
LIMIT 1;
" )

if [ -z "$BEST_DAY" ]; then
    echo "No valid data found for $CITY"
    exit 1
fi

echo "City: $CITY"
echo "Busiest data day: $BEST_DAY"


DATAFILE="${TXT_DIR}/${CITY}_${BEST_DAY}_feellike.dat"
PLOTFILE="${PLOT_DIR}/${CITY}_${BEST_DAY}_feellike.png"

$MYSQL -e "
USE weather_db;
SELECT UNIX_TIMESTAMP(date_time), apparent_temperature
FROM weather_data
WHERE city='$CITY' AND DATE(date_time)='$BEST_DAY'
ORDER BY date_time;
" | sed '1d' > "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1200,600
set output "$PLOTFILE"
set title "Feel-Like Temperature on $BEST_DAY for $CITY"
set xlabel "Time of Day"
set xdata time
set timefmt "%s"
set format x "%H:%M"
set ylabel "Feel-Like Temp (°C)"
set grid
plot "$DATAFILE" using 1:2 with lines lw 2 linecolor "orange" title "Feel-Like Temperature"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
