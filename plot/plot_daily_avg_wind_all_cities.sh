MYSQL="/opt/lampp/bin/mysql -u root"

TXT_DIR="avg_wind_all/txts"
PLOT_DIR="avg_wind_all/plots"

mkdir -p "$TXT_DIR" "$PLOT_DIR"

DATAFILE="${TXT_DIR}/daily_avg_wind_all.dat"
PLOTFILE="${PLOT_DIR}/daily_avg_wind_all.png"

CITIES=(
"Kuala_Lumpur"
"George_Town"
"Kota_Kinabalu"
"Kuching"
"Johor_Bahru"
"Ipoh"
"Melaka"
"Alor_Setar"
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
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Kuala_Lumpur'  AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='George_Town'   AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Kota_Kinabalu' AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Kuching'       AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Johor_Bahru'   AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Ipoh'          AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Melaka'        AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Alor_Setar'    AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Paris'         AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Ottawa'        AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Canberra'      AND DATE(date_time)=d.day),
       (SELECT AVG(windspeed) FROM weather_data WHERE city='Tokyo'         AND DATE(date_time)=d.day)
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
set title "Daily Average Wind Speed for All Cities"
set xlabel "Day"
set xdata time
set timefmt "%Y-%m-%d"
set format x "%d-%m"
set autoscale xfix
set ylabel "Wind Speed (km/h)"
set grid
set datafile separator "\t"
set datafile missing "NaN"
set key autotitle columnhead
# Skip header (line 1) with 'every ::1'
plot for [i=2:13] "$DATAFILE" using 1:i every ::1 with lines lw 2 title columnheader(i)
EOF

# echo "Plot saved as $PLOTFILE"
# echo "Data saved as $DATAFILE"
