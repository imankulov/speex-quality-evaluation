# -*- makefile -*-

# SQL_DATA: The directory where input, output, src and summary subdirs reside
SQE_DATA ?= .
MAKEFLAGS += --jobs 5 --max-load 2.5

help:
	cat help.txt

include conf.mk
include summary.mk

# This is the rule to prepare input file from "source"
# input file is a 8kHz file
#$(input_files): input/%.wav: src/%.wav
$(SQE_DATA)/input/%.wav: $(SQE_DATA)/src/%.wav
ifdef SQE_RESAMPLE_ONLY
	./scripts/prepare.sh $< $@ resample-only
else
	./scripts/prepare.sh $< $@
endif

# This is generic rule to make the core experiment 
# output/pcmu/woman01.wav depends from input/woman01.wav
.SECONDEXPANSION:
$(SQE_DATA)/output/%.wav: $(SQE_DATA)/input/$$(notdir %).wav
	./scripts/emulate.sh $< $@

# This is the rule to make pesq quality evaluation and store them to .pesq file
# output/pcmu/01.pesq depends from output/pcmu/01.wav
$(SQE_DATA)/output/%.pesq: $(SQE_DATA)/output/%.wav
	./scripts/pesq_output.py $<

# This is PESQ values for speech samples with no codec impairments
# (when input speech sample is compared with itself
# The rule to get all input PESQ values has the name ref_pesq
ref_pesq: $(input_pesq_files)
$(SQE_DATA)/input/%.pesq: $(SQE_DATA)/input/%.wav
	./scripts/pesq_input.py $<

# This is a rule to make full experiment for one codec and one rule to make it all
# "codec" depends from $(SQE_DATA)/output/codec/woman01.pesq, output/codec/woman02.pesq, etc
$(codecs): %: prepare $(addsuffix .pesq,$(basename $(subst src/,output/%/,$(wildcard $(SQE_DATA)/src/*))))
codecs: ref_pesq $(codecs)

prepare:
	mkdir -p $(SQE_DATA)/input $(SQE_DATA)/graphics $(SQE_DATA)/summary
	for c in $(codecs); do mkdir -p $(SQE_DATA)/output/$$c; done

clean:
	rm -f $(SQE_DATA)/input/* $(SQE_DATA)/output/*/* $(SQE_DATA)/graphics/* $(SQE_DATA)/summary/*

# auxiliary rules
.PHONY: prepare all help summary ref_pesq $(codecs)
.SILENT: help prepare
