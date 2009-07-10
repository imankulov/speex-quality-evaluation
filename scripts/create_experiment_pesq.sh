#!/bin/bash
# This create one file with PESQ derived MOS LQO data based on a bunch of .pesq files
# Useful to store data into the R statistics.
# Try this:
# > data = read.table("experiment.pesq", header=TRUE)
# > attach(data)
# > boxplot(mos~codec)
# > bw = factor(bandwidth, levels=bandwidth, labels=codec)
# > boxplot(mos~bw)
bandwidth_pcma=64000
bandwidth_pcmu=64000
bandwidth_g726_16=16000
bandwidth_g726_24=24000
bandwidth_g726_32=32000
bandwidth_g726_40=40000
bandwidth_g728=16000
bandwidth_g729=8000
bandwidth_g723_53=5300
bandwidth_g723_63=6300
bandwidth_amr_4750=4750
bandwidth_amr_5150=5150
bandwidth_amr_5900=5900
bandwidth_amr_6700=6700
bandwidth_amr_7400=7400
bandwidth_amr_7950=7950
bandwidth_amr_10200=10200
bandwidth_amr_12200=12200
bandwidth_speex_1=2150
bandwidth_speex_8=3950
bandwidth_speex_2=5950
bandwidth_speex_3=8000
bandwidth_speex_4=11000
bandwidth_speex_5=15000
bandwidth_speex_6=18200
bandwidth_speex_7=24600
bandwidth_speex_vbr_3000=3000
bandwidth_speex_vbr_4000=4000
bandwidth_speex_vbr_5000=5000
bandwidth_speex_vbr_7000=7000
bandwidth_speex_vbr_8000=8000
bandwidth_speex_vbr_10000=10000
bandwidth_speex_vbr_12000=12000
bandwidth_speex_vbr_15000=15000
bandwidth_ilbc=13333

out=experiment.pesq
echo -e "codec\tlanguage\tgender\tmos\tbandwidth" > $out
for filename in output/*/*.pesq; do
	read codec language gender < <(echo "$filename" | sed -r 's,^output/([^/]+)/([^_]+)_(.*)..\.pesq$,\1 \2 \3,g')
	eval bw=\${bandwidth_$codec}
	echo -e "$codec\t$language\t$gender\t$(cat $filename)\t$bw" >> $out
done
