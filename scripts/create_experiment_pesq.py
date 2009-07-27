#!/usr/bin/env python
from __future__ import with_statement
"""
This script creates one file with PESQ derived MOS LQO data based on a bunch of .pesq files
Useful to store data into the R statistics.
Try this:

> data = read.table("summary/experiment.dat", header=TRUE)
> attach(data)
> boxplot(mos~codec)
> bw = factor(bandwidth, levels=bandwidth, labels=codec)
> boxplot(mos~bw)
"""
import glob, re
import vqmetrics

output_file = 'summary/experiment.dat'

bandwidth = dict(
    pcma=64000,
    pcmu=64000,
    g726_16=16000,
    g726_24=24000,
    g726_32=32000,
    g726_40=40000,
    g728=16000,
    g729=8000,
    g723_53=5300,
    g723_63=6300,
    amr_4750=4750,
    amr_5150=5150,
    amr_5900=5900,
    amr_6700=6700,
    amr_7400=7400,
    amr_7950=7950,
    amr_10200=10200,
    amr_12200=12200,
    speex_1=2150,
    speex_8=3950,
    speex_2=5950,
    speex_3=8000,
    speex_4=11000,
    speex_5=15000,
    speex_6=18200,
    speex_7=24600,
    speex_vbr_3000=3000,
    speex_vbr_4000=4000,
    speex_vbr_5000=5000,
    speex_vbr_7000=7000,
    speex_vbr_8000=8000,
    speex_vbr_10000=10000,
    speex_vbr_12000=12000,
    speex_vbr_15000=15000,
    ilbc=13333,
    gsmfr=13200,
)


r =  re.compile(r'output/(.+)/(.+)_(.+)([0-9]{2}).pesq')
files = sorted(glob.glob('output/*/*.pesq'))

o = open(output_file, 'w')
o.write('codec\tlanguage\tgender\trefmos\tmos\tbandwidth\tie\n')
for filename in files:
    codecs, language, gender, id = r.match(filename).groups()
    codec = codecs.split('__')[0]
    bw = bandwidth[codec]
    with open(filename, 'r') as f:
        degmos = float(f.read())
    with open('input/%(language)s_%(gender)s%(id)s.pesq' % locals()) as f:
        refmos = float(f.read())
    refr = vqmetrics.mos2r(refmos)
    degr = vqmetrics.mos2r(degmos)
    ie = refr - degr
    o.write(
        '%(codecs)s\t%(language)s\t%(gender)s\t'  % locals() + \
        '%(refmos).2f\t%(degmos).2f\t%(bw)d\t%(ie)d\n' % locals())
o.close()
