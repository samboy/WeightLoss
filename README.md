# What this is

This is a pretty chart showing my weight loss progress.

# Requirements

* A POSIX compatible *NIX system (e.g. Linux, either with the GNU
  user space utilities, or with a Busybox userspace)
* gnuplot

# How to make this chart

The file `weight-chart` is a plain text file which has the date
(YYYY MM DD) followed by my weight (in pounds) for that day.

The shell script `weight-chart-process.sh` is a POSIX compliant
shell script which will take the contents of `weight-chart` and make
a pretty chart out of it.

# How to change the vertical scaling of the chart

The chart currently has a fixed vertical scale.  This can be changed
by editing the following line in `weight-chart-process.sh`:

```
set yrange [155:205]
```

