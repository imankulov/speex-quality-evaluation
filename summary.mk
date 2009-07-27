# Create summary data using raw experiment results 

summary: summary/experiment.dat graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex

graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex: summary/experiment.dat
	R --slave --no-save < ./scripts/p862.r

summary/experiment.dat: $(pesq_files)
	./scripts/create_experiment_pesq.py


clean_summary:
	rm -f summary/experiment.dat graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex
