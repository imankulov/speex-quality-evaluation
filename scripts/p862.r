library(xtable)
source("scripts/helpers.r")

# Load experiment data
sqe_data = Sys.getenv("SQE_DATA", ".")
datfile = paste(sqe_data, "summary/experiment.dat", sep="/")
experiment = read.table(datfile, header=TRUE)

# Load P.862.1 data
codecs <- c("pcmu", "pcma", "g726_16", "g726_24", "g726_32", "g726_40", "g728", "g729", "g723_53", "g723_63")
pesq_p862_f1 <- c(4.46, 4.28, 2.50, 3.34, 3.89, 4.18, 3.95, 3.95, 3.65, 3.81)
pesq_p862_f2 <- c(4.45, 4.42, 3.12, 3.76, 4.07, 4.33, 4.27, 4.08, 3.67, 3.80)
pesq_p862_m1 <- c(4.49, 4.36, 2.86, 3.82, 4.25, 4.35, 4.19, 4.17, 3.90, 3.97)
pesq_p862_m2 <- c(4.47, 4.31, 2.97, 3.80, 4.21, 4.40, 4.22, 4.15, 3.95, 4.07)

# mean value for male and female speech samples
pesq_p862_female <- apply(cbind(pesq_p862_f1, pesq_p862_f2), 1, mean)
pesq_p862_male <- apply(cbind(pesq_p862_m1, pesq_p862_m2), 1, mean)

p862=rbind(
	data.frame(gender='male', mos=pesq_p862_male, codec=codecs, stringsAsFactors=FALSE),
	data.frame(gender='female', mos=pesq_p862_female, codec=codecs, stringsAsFactors=FALSE)
)

# Create the linear interpolation of the test results on purpose to define 
# experimental bias and scale transformation

ret_median = c()   # Experimental data
ret_p862 = c()     # P.862.1 data
for (n in 1:nrow(p862)) {
	r = p862[n,]
	experiment_data = with(experiment, experiment$mos[gender==r$gender & codec==r$codec])
	ret_median = c(ret_median, median(experiment_data))
	ret_p862 = c(ret_p862, r$mos)
}

# Find an approx. line and new corrected MOS values
z = line(ret_median, ret_p862)
experiment$mos2 = z$coefficients[1] + z$coefficients[2]*experiment$mos

#make a plot and save it in the file
psfile = paste(sqe_data, "graphics/p862_interpolation.eps", sep="/")
postscript(psfile, height=5, width=5, pointsize=10,
	horizontal=FALSE, onefile=FALSE, paper="special")
plot(ret_median, ret_p862, xlab="Experimental MOS data", ylab="Reference MOS data")
abline(z)
dev.off()

# generate summarized MOS result for both male and female voices
for (g in levels(experiment$gender)) {
	exp = experiment[experiment$gender==g,]
	summarized = data.frame(
		mos=with(exp, tapply(mos, codec, median)),
		mos2=with(exp, tapply(mos2, codec, median)),
		p25=with(exp, tapply(mos2, codec, function(x){quantile(x)["25%"]})),
		p75=with(exp, tapply(mos2, codec, function(x){quantile(x)["75%"]})),
		iqr=with(exp, tapply(mos2, codec, IQR)),
		p862=with(exp, 
			tapply(codec, codec, function(x){
				p862[p862$codec==levels(codec)[x[1]] & p862$gender==g, "mos"] 
			}))
	)
	#summarized$in_iqr = summarized$p862 < summarized$p75 & summarized$p862 > summarized$p25
	summarized$codec_id = codec_name(rownames(summarized))

	tab = xtable(summarized[, c(7, 1, 2, 5, 6)])
	caption(tab) <- paste("MOS LQO values (", g, " voices)", sep="")
	colnames(tab) <- c("Codec ID", "MOS (exp)", "MOS (corr)", "IQR", "MOS (ref)")
	rownames(tab) <- 1:nrow(summarized)
	texfile=paste(sqe_data, "/summary/", g, "_p862.tex", sep="")
	print(tab, file=texfile)
}
