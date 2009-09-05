#!/bin/bash
# perform the emulation 
# $1 -- input file
# $2 -- output file

# encoding options
g726_16_options="--codec=G726-16"
g726_24_options="--codec=G726-24"
g726_32_options="--codec=G726-32"
g726_40_options="--codec=G726-40"
g728_options="--codec=G728"
g729_options="--codec=G729"
g723_53_options="--codec=G723 --bitrate=5300"
g723_63_options="--codec=G723 --bitrate=6300"
amr_4750_options="--codec=AMR --bitrate=4750"
amr_5150_options="--codec=AMR --bitrate=5150"
amr_5900_options="--codec=AMR --bitrate=5900"
amr_6700_options="--codec=AMR --bitrate=6700"
amr_7400_options="--codec=AMR --bitrate=7400"
amr_7950_options="--codec=AMR --bitrate=7950"
amr_10200_options="--codec=AMR --bitrate=10200"
amr_12200_options="--codec=AMR --bitrate=12200"
speex_1_options="--codec=speex/8000 --speex-quality=0"
speex_8_options="--codec=speex/8000 --speex-quality=1"
speex_2_options="--codec=speex/8000 --speex-quality=2"
speex_3_options="--codec=speex/8000 --speex-quality=4"
speex_4_options="--codec=speex/8000 --speex-quality=6"
speex_5_options="--codec=speex/8000 --speex-quality=8"
speex_6_options="--codec=speex/8000 --speex-quality=9"
speex_7_options="--codec=speex/8000 --speex-quality=10"
speex_vbr_3000_options="--codec=speex/8000 --bitrate=3000"
speex_vbr_4000_options="--codec=speex/8000 --bitrate=4000"
speex_vbr_5000_options="--codec=speex/8000 --bitrate=5000"
speex_vbr_7000_options="--codec=speex/8000 --bitrate=7000"
speex_vbr_8000_options="--codec=speex/8000 --bitrate=8000"
speex_vbr_10000_options="--codec=speex/8000 --bitrate=10000"
speex_vbr_12000_options="--codec=speex/8000 --bitrate=12000"
speex_vbr_15000_options="--codec=speex/8000 --bitrate=15000"
pcmu_options="--codec=PCMU"
pcma_options="--codec=PCMA"
ilbc_options="--codec=iLBC"
gsmfr_options="--codec=GSM/8000"

mkdir -p $(dirname $2)
codecs=$(basename $(dirname $2))
file1=$(tempfile -s .wav)
file2=$(tempfile -s .wav)
trap 'rm -f "$file1" "$file2"' INT QUIT TERM EXIT
cp -a $1 $file1
for codec in $(sed 's/__/ /g' <<<$codecs); do
	eval options=\$${codec}_options
	emulator $options -i $file1 -o $file2 -p empty
	mv $file2 $file1
done
mv $file1 $2
