# all codecs with all options
codecs := g726_16 g726_24 g726_32 g726_40 \
	g728 g729 g723_53 g723_63 \
	amr_4750 amr_5150 amr_5900 amr_6700 amr_7400 amr_7950 amr_10200 amr_12200 \
	speex_1 speex_8 speex_2 speex_3 speex_4 speex_5 speex_6 speex_7 \
	speex_vbr_3000 speex_vbr_4000 speex_vbr_5000 speex_vbr_7000 \
	speex_vbr_8000 speex_vbr_10000 speex_vbr_12000 speex_vbr_15000 \
	pcmu pcma ilbc gsmfr \
	g726_32__g726_32 g728__g728 g729__g729 g729__g729__g729 gsmfr__gsmfr


# Source (raw data)
src_files := $(wildcard $(SQE_DATA)/src/*)
input_files := $(subst src,input,$(src_files))
input_pesq_files := $(subst wav,pesq,$(input_files))
output_files := $(shell for c in $(codecs); do ls $(SQE_DATA)/src/* | sed "s,src/,output/$${c}/," ; done)
pesq_files := $(shell for c in $(codecs); do ls $(SQE_DATA)/src/* | sed "s,src/,output/$${c}/,; s,wav,pesq," ; done)


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
	echo "* Input PESQ files"
	echo $(input_pesq_files) | tr ' ' '\n' | head -n3
	echo ...
	echo $(input_pesq_files) | tr ' ' '\n' | tail -n2
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
