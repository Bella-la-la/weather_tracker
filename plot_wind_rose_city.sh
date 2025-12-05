CITY="$1"
if [ -z "$CITY" ]; then
    echo "Usage: ./plot_wind_rose_city.sh <City_Name>"
    exit 1
fi

MYSQL="/opt/lampp/bin/mysql -u root"

TXT_DIR="wind_rose_city/txts"
PLOT_DIR="wind_rose_city/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE=$TXT_DIR/${CITY}_wind_rose.dat
PLOTFILE=$PLOT_DIR/${CITY}_wind_rose.png

$MYSQL -N -e "
USE weather_db;

SELECT 
    FLOOR(winddirection / 30) * 30 AS bin_start,
    COUNT(*) AS freq
FROM weather_data
WHERE city='$CITY'
  AND DATE(date_time) <> '2025-11-08'
GROUP BY bin_start
ORDER BY bin_start;
" > "$DATAFILE"

for angle in 0 30 60 90 120 150 180 210 240 270 300 330
do
    if ! grep -q "^$angle" "$DATAFILE" ; then
        echo -e "$angle\t0" >> "$DATAFILE"
    fi
done

sort -n "$DATAFILE" -o "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1200,1200
set output "$PLOTFILE"
set title "Wind Rose for $CITY"
set polar
set angle degrees
set grid polar
set style fill solid 1.0
plot "$DATAFILE" using 1:(\$2) with filledcurves closed lc rgb "blue" title "$CITY"
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
