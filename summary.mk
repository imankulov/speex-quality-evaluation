# Create summary data using raw experiment results 

summary: $(SQE_DATA)/summary/experiment.dat $(SQE_DATA)/graphics/p862_interpolation.eps \
	$(SQE_DATA)/summary/male_p862.tex $(SQE_DATA)/summary/female_p862.tex \
	$(SQE_DATA)/graphics/p833_interpolation.eps $(SQE_DATA)/summary/p833.tex

$(SQE_DATA)/graphics/p862_interpolation.eps $(SQE_DATA)/summary/male_p862.tex $(SQE_DATA)/summary/female_p862.tex: $(SQE_DATA)/summary/experiment.dat
	R --slave --no-save < ./scripts/p862.r

$(SQE_DATA)/summary/experiment.dat: $(pesq_files)
	./scripts/create_experiment_pesq.py


$(SQE_DATA)/graphics/p833_interpolation.eps $(SQE_DATA)/summary/p833.tex: $(SQE_DATA)/summary/experiment.dat
	 R --slave --no-save < ./scripts/p833.r

clean_summary:
	rm -f $(SQE_DATA)/summary/experiment.dat \
		$(SQE_DATA)/graphics/p862_interpolation.eps \
		$(SQE_DATA)/summary/male_p862.tex \
		$(SQE_DATA)/summary/female_p862.tex \
		$(SQE_DATA)/graphics/p833_interpolation.eps \
		$(SQE_DATA)/summary/p833.tex
