#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1]
set yrange [0:1]
set grid
plot 'examples/2Dhistogram.dat' using 1:2 title 'Distribution of simulated events' at .4, .9 with points pointtype 7 pointsize .3
