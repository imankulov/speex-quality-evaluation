# all codecs with all options
codecs := g726_16 g726_24 g726_32 g726_40 \
	g728 g729 g723_53 g723_63 \
	amr_4750 amr_5150 amr_5900 amr_6700 amr_7400 amr_7950 amr_10200 amr_12200 \
	speex_1 speex_8 speex_2 speex_3 speex_4 speex_5 speex_6 speex_7 \
	speex_vbr_3000 speex_vbr_4000 speex_vbr_5000 speex_vbr_7000 \
	speex_vbr_8000 speex_vbr_10000 speex_vbr_12000 speex_vbr_15000 \
	pcmu pcma ilbc

# encoding options
g726_16_options := --codec=G726-16
g726_24_options := --codec=G726-24
g726_32_options := --codec=G726-32
g726_40_options := --codec=G726-40
g728_options := --codec=G728
g729_options := --codec=G729
g723_53_options := --codec=G723 --bitrate=5300
g723_63_options := --codec=G723 --bitrate=6300
amr_4750_options := --codec=AMR --bitrate=4750
amr_5150_options := --codec=AMR --bitrate=5150
amr_5900_options := --codec=AMR --bitrate=5900
amr_6700_options := --codec=AMR --bitrate=6700
amr_7400_options := --codec=AMR --bitrate=7400
amr_7950_options := --codec=AMR --bitrate=7950
amr_10200_options := --codec=AMR --bitrate=10200
amr_12200_options := --codec=AMR --bitrate=12200
speex_1_options := --codec=speex/8000 --speex-quality=0
speex_8_options := --codec=speex/8000 --speex-quality=1
speex_2_options := --codec=speex/8000 --speex-quality=2
speex_3_options := --codec=speex/8000 --speex-quality=4
speex_4_options := --codec=speex/8000 --speex-quality=6
speex_5_options := --codec=speex/8000 --speex-quality=8
speex_6_options := --codec=speex/8000 --speex-quality=9
speex_7_options := --codec=speex/8000 --speex-quality=10
speex_vbr_3000_options := --codec=speex/8000 --bitrate=3000
speex_vbr_4000_options := --codec=speex/8000 --bitrate=4000
speex_vbr_5000_options := --codec=speex/8000 --bitrate=5000
speex_vbr_7000_options := --codec=speex/8000 --bitrate=7000
speex_vbr_8000_options := --codec=speex/8000 --bitrate=8000
speex_vbr_10000_options := --codec=speex/8000 --bitrate=10000
speex_vbr_12000_options := --codec=speex/8000 --bitrate=12000
speex_vbr_15000_options := --codec=speex/8000 --bitrate=15000
pcmu_options := --codec=PCMU
pcma_options := --codec=PCMA
ilbc_options := --codec=iLBC

# Source (raw data)
src_files := $(wildcard src/*)
input_files := $(subst src,input,$(src_files))
output_files := $(shell for c in $(codecs); do ls src/* | sed "s,src/,output/$${c}/," ; done)
pesq_files := $(shell for c in $(codecs); do ls src/* | sed "s,src/,output/$${c}/,; s,wav,pesq," ; done)


test_conf:
	echo
	echo "* Source files"
	echo $(src_files) | tr ' ' '\n' | head -n3 
	echo ...
	echo $(src_files) | tr ' ' '\n' | tail -n2
	echo
	echo "* Input files"
	echo $(input_files) | tr ' ' '\n' | head -n3
	echo ...
	echo $(input_files) | tr ' ' '\n' | tail -n2
	echo
	echo "* Output files"
	echo $(output_files) | tr ' ' '\n' | head -n3
	echo ...
	echo $(output_files) | tr ' ' '\n' | tail -n2
	echo
	echo "* PESQ files"
	echo $(pesq_files) | tr ' ' '\n' | head -n3
	echo ...
	echo $(pesq_files) | tr ' ' '\n' | tail -n2

.SILENT: test_conf
.SECONDARY: $(input_files) $(output_files)
