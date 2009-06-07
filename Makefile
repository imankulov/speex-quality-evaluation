# -*- makefile -*-
MAKEFLAGS += --jobs 5 --max-load 2.5

# all codecs with all options
codecs := g726_16 g726_24 g726_32 g726_40 \
	g728 g729 g723_53 g723_63 \
	amr_4750 amr_5150 amr_5900 amr_6700 amr_7400 amr_7950 amr_10200 amr_12200 \
	speex_1 speex_8 speex_2 speex_3 speex_4 speex_5 speex_6 speex_7 \
	speex_vbr_2000 speex_vbr_2500 speex_vbr_3000 speex_vbr_4000 speex_vbr_5000 \
	speex_vbr_7000 speex_vbr_8000 speex_vbr_10000 speex_vbr_12000 speex_vbr_15000 \
	pcmu pcma

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

# there is list of secondary files which should never be removed
input_files := $(subst src,input,$(wildcard src/*))
output_files := $(shell for c in $(codecs); do ls src/* | sed "s,src/,output/$${c}/," ; done)
pesq_files := $(shell for c in $(codecs); do ls src/* | sed "s,src/,output/$${c}/,; s,wav,pesq," ; done)


help:
	echo "You must select one of the target corresponding to some codec"
	echo "(i.e. 'make pcmu' or 'make speex_4') or just type 'make all'"

# This is the rule to prepare input file from "source"
# input file is a 8kHz file
#$(input_files): input/%.wav: src/%.wav
input/%.wav: src/%.wav
	./prepare.sh $< $@

# This is generic rule to make the core experiment 
# output/pcmu/woman01.wav depends from input/woman01.wav
.SECONDEXPANSION:
output/%.wav: input/$$(notdir %).wav
	emulator $($(shell echo "$@" | sed -r 's,.*/(.*)/.*,\1,')_options) -i $< -o $@ -p empty

# This is the rule to make pesq quality evaluation and store them to .pesq file
# output/pcmu/01.pesq depends from output/pcmu/01.wav
output/%.pesq: output/%.wav
	pesq +8000 input/$(shell echo "$<" | sed -r 's,.*/.*/(.*),\1,') $<  | tail -n1 | egrep -o '[0-9.]+$$' > $@

# This is a rule to make full experiment for one codec and one rule to make it all
# codec depends from output/codec/woman01.pesq, output/codec/woman02.pesq, etc
$(codecs): %: prepare $(addsuffix .pesq,$(basename $(subst src/,output/%/,$(wildcard src/*))))
all: $(codecs)


prepare:
	mkdir -p input 
	for c in $(codecs); do mkdir -p output/$$c; done

.PHONY: prepare all help $(codecs)
.SILENT: help
.SECONDARY: $(input_files) $(output_files)
