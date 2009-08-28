# Create summary data using raw experiment results 

summary: summary/experiment.dat graphics/p862_interpolation.eps summary/male_p862.tex summary/female_p862.tex \
	graphics/p833_interpolation.eps summary/p833.tex

graphics/p862_interpolation.eps summary/male_p862.tex summary/female_p862.tex: summary/experiment.dat
	R --slave --no-save < ./scripts/p862.r

summary/experiment.dat: $(pesq_files)
	./scripts/create_experiment_pesq.py


graphics/p833_interpolation.eps summary/p833.tex: summary/experiment.dat
	 R --slave --no-save < ./scripts/p833.r

clean_summary:
	rm -f summary/experiment.dat graphics/p862_interpolation.eps summary/male_p862.tex summary/female_p862.tex \
		graphics/p833_interpolation.eps summary/p833.tex
