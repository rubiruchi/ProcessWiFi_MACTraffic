#This script plots the percentage of frames in available frame sizes.
#For each frame size percentage of frames are calculated as per the
#commands in CommandToCountEachSize.txt in the same folder
gnuplot << eor

set terminal png font "Helvetica" 14
set output 'CDF.png'
set datafile separator ","
set boxwidth 0.2 relative
set key inside top right 

set key samplelen 2
set style histogram cluster gap 1.5
set style fill solid 1.0 border -1

set ylabel "Percentage of Probe Responses"
set xlabel "Number of BSSs on Same/Overlapping Channel"
set xtics rotate by -70 at 0.3,4
set yrange [0:100]
set ytics 10

plot "/home/dherytaj/Temp_Merged_CDF/1PreqNPres/Merged_1PreqNPres.csv" u ($0 + 0.3):4:xtic(1) w boxes lc rgb "red" title "SIGCOMM '08",  "" u ($0 + 0.5):3 w boxes lc rgb "green"  title 'IIT-Bombay',  "" u ($0 + 0.7):2 w boxes lc rgb "blue"  title 'IIIT-Delhi
exit

eor
