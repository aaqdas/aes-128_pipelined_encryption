# Set the terminal type and output file
set terminal pngcairo enhanced font 'Helvetica,10'
set output 'power_profile.png'

# Set the title and labels
set title "Power Profile of /aes_pipelined"
set xlabel "Simulation Time (fs)"
set ylabel "Power (uW)"

# Set grid and style
set grid
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5

# Set x-range based on data
set xrange [0:305612500.0]

# Plot the data
plot 'joules_waveform_pwr.native.data' using 1:2 with linespoints linestyle 1 title 'Power Profile'
