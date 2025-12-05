MYSQL="/opt/lampp/bin/mysql -u root"
TXT_DIR="temp_stability_capitals/txts"
PLOT_DIR="temp_stability_capitals/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE="${TXT_DIR}/daily_temp_stability_capitals.dat"
PLOTFILE="${PLOT_DIR}/daily_temp_stability_capitals.png"

CITIES=(
"Paris"
"Ottawa"
"Canberra"
"Tokyo"
)

{
    printf "Day"
    for CITY in "${CITIES[@]}"; do
        printf "\t%s" "$CITY"
    done
    printf "\n"
} > "$DATAFILE"

$MYSQL -N -e "
USE weather_db;

SELECT d.day,
       (SELECT MAX(temperature) - MIN(temperature) FROM weather_data WHERE city='Paris'    AND DATE(date_time)=d.day),
       (SELECT MAX(temperature) - MIN(temperature) FROM weather_data WHERE city='Ottawa'   AND DATE(date_time)=d.day),
       (SELECT MAX(temperature) - MIN(temperature) FROM weather_data WHERE city='Canberra' AND DATE(date_time)=d.day),
       (SELECT MAX(temperature) - MIN(temperature) FROM weather_data WHERE city='Tokyo'    AND DATE(date_time)=d.day)
FROM (
    SELECT DISTINCT DATE(date_time) AS day
    FROM weather_data
    WHERE DATE(date_time) <> '2025-11-08'
) AS d
ORDER BY d.day;
" >> "$DATAFILE"

gnuplot <<EOF
set terminal pngcairo size 1500,800
set output "$PLOTFILE"
set title "Daily Temperature Stability (Max-Min) for World Capitals"
set xlabel "Day"
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%m"
set autoscale xfix
set ylabel "Temperature Stability (°C)"
set grid
set datafile separator "\t"
set datafile missing "NaN"
set key autotitle columnhead
plot for [i=2:5] "$DATAFILE" using 1:i every ::1 with lines lw 2 title columnheader(i)
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
