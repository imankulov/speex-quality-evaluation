# -*- makefile -*-
MAKEFLAGS += --jobs 5 --max-load 2.5

include conf.mk


help:
	echo "You must select one of the target corresponding to some codec"
	echo "(i.e. 'make pcmu' or 'make speex_4') or just type 'make all'"

# This is the rule to prepare input file from "source"
# input file is a 8kHz file
#$(input_files): input/%.wav: src/%.wav
input/%.wav: src/%.wav
	./scripts/prepare.sh $< $@

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
# "codec" depends from output/codec/woman01.pesq, output/codec/woman02.pesq, etc
$(codecs): %: prepare $(addsuffix .pesq,$(basename $(subst src/,output/%/,$(wildcard src/*))))
all: $(codecs)

prepare:
	mkdir -p input 
	for c in $(codecs); do mkdir -p output/$$c; done

experiment.pesq: $(pesq_files)
	./scripts/create_experiment_pesq.sh


# auxiliary rules
.PHONY: prepare all help $(codecs)
.SILENT: help prepare
