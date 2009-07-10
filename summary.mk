# Create summary data using raw experiment results 

summary: summary/experiment.pesq graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex

graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex: summary/experiment.pesq
	R --slave --no-save < ./scripts/p862.r

summary/experiment.pesq: $(pesq_files)
	./scripts/create_experiment_pesq.sh


clean_summary:
	rm -f summary/experiment.pesq graphics/interpolation.eps summary/male_p862.tex summary/female_p862.tex
