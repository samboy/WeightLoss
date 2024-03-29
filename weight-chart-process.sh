#!/bin/sh

# Needed: GNUplot

cat weight-chart | awk '
	BEGIN {
	       julian[1] = 0
	       julian[2] = 31 # January: 31 days
	       julian[3] = julian[2] + 28 # February: Leap years handled below
	       julian[4] = julian[3] + 31 # March: 31 days
	       julian[5] = julian[4] + 30 # April: 30 days
	       julian[6] = julian[5] + 31 # May: 31 days
	       julian[7] = julian[6] + 30 # June: 30 days
	       julian[8] = julian[7] + 31 # July: 31 days
	       julian[9] = julian[8] + 31 # August: 31 days
	       julian[10] = julian[9] + 30 # September: 30 days
	       julian[11] = julian[10] + 31 # October: 31 days
	       julian[12] = julian[11] + 30 # November: 30 days
	       for(month=1 ; month <= 12 ; month++) {
	           leapyear[month] = julian[month] 
		   if(month > 2) {
		       leapyear[month]++
		   }
	       }

	       # How many days since 2000 on January 1 of a given year
	       jdays[2000] = 0
	       for(year = 2001; year < 2200; year++) {
	           jdays[year] = jdays[year - 1] + 365
		   if(year % 4 == 0 && year != 2100) { # Good until 2200
                      jdays[year]++
		   }
	       }

	       print "Day,Weight"
	       zstart = -1
	       zjday = -1
	       jcounter = 0
	       lastjday = 0
	   }

	       {year = $1 + 0
	        month = $2 + 0
	        day = $3 + 0
		weight = $5
		if(year % 4 != 0 || year == 2100) { # Good until 2200
		    jday = jdays[year] + julian[month] + day
		} else {
		    jday = jdays[year] + leapyear[month] + day
		}
		print $1 "-" $2 "-" $3 "," weight

		w[jday] = weight # Weight on a given day
		if(lastjday > 1 && (jday - lastjday) > 0) {
                     delta[jday] = (weight - w[lastjday]) / (jday - lastjday)
		     # Interpolate for missing days
		     estimatedweight = weight
		     for(counter = jday - 1; counter > lastjday; counter--) {
		         delta[counter] = delta[jday]
			 estimatedweight -= delta[jday]
			 w[counter] = estimatedweight
		     }
		}
		lastjday = jday

		if(zstart == -1) {zjday = jday 
		                  zstart = weight}
		}
	END {avg = ((weight - zstart) / (jday - zjday)) * -1
	     deltasum = 0
	     if(w[jday - 7]) { deltasum = w[jday] - w[jday-7] }
	     wavg = (deltasum * -1) / 7
             print "Daily weight loss (overall): " avg | "cat 1>&2"
	     print "Daily weight loss (last week): " wavg | "cat 1>&2"
	     }
		' > weight.csv

START=$( head -2 weight.csv | tail -1 | cut -f1 -d, )
END=$( tail -1 weight.csv | cut -f1 -d, )

cat > weight.gnuplot << EOF
set terminal pdfcairo size 10in,7.5in enhanced font 'Caulixtla009Serif,25'
set output 'weight.pdf'
set xdata time
set timefmt "%Y-%m-%d"
set xrange ["$START":"$END"]
set yrange [155:205]
set title 'Weight loss progress 2023'
set datafile separator ','
set key left autotitle columnhead
set grid xtics ytics lw 1
plot "weight.csv" using 1:2 with line lw 5
EOF

gnuplot weight.gnuplot

