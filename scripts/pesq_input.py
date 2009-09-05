#!/usr/bin/env python
import sys, re
import vqmetrics

# parse degraded file name and get input and pesq filenames
degraded_file = sys.argv[1]
reference_file = degraded_file
pesq_file = degraded_file.replace('.wav', '.pesq')

# get pesq result and store in in the pesq file
pesqres = '%.3f\n' % vqmetrics.pesq(reference_file, degraded_file)[1]
f = open(pesq_file, 'w')
f.write(pesqres)
f.close()
