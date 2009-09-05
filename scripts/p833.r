library(xtable)

# Load experiment data
sqe_data = Sys.getenv("SQE_DATA", ".")
datfile = paste(sqe_data, "summary/experiment.dat", sep="/")
experiment = read.table(datfile, header=TRUE)


# 1. AMR 12.200 instead of EFR
# 2. no HR
# Load P.833 data 
pesq_p833 <- c(0, 0, 5, 7, 7, 10, 14, 14, 20, 20, 25, 30, 40, 50)
codecs <- c("pcmu", "pcma", "amr_12200",   "g726_32", "g728", "g729",
"g726_32__g726_32", "g728__g728", "gsmfr", "g729__g729", "g726_24",
"g729__g729__g729", "gsmfr__gsmfr", "g726_16")


p833 = data.frame(ie=pesq_p833, codec=codecs, stringsAsFactors=FALSE);



ret_median = c()   # Experimental data
ret_p833 = c()     # P.833.1 data
for (n in 1:nrow(p833)) {
        r = p833[n,]
        experiment_data = with(experiment, experiment$ie[codec==r$codec])
        ret_median = c(ret_median, median(experiment_data))
        ret_p833 = c(ret_p833, r$ie)
}

# Find an approx. line and new corrected MOS values
z = line(ret_median, ret_p833)
experiment$ie2 = z$coefficients[1] + z$coefficients[2]*experiment$ie

#make a plot and save it in the file
psfile = paste(sqe_data, "graphics/p833_interpolation.eps", sep="/")
postscript(psfile, height=5, width=5, pointsize=10,
	horizontal=FALSE, onefile=FALSE, paper="special")
plot(ret_median, ret_p833, xlab="Experimental Ie data", ylab="Reference Ie data")
abline(z)
# subscribe top 10 distant points
top5 = order( abs(residuals(z)), decreasing=TRUE )[1:5]
text( ret_median[top5]-2, ret_p833[top5]-2, codecs[top5]  )

dev.off()



# generate summarized MOS result
summarized = data.frame(
	ie=with(experiment, tapply(ie, codec, median)),
	ie2=with(experiment, tapply(ie2, codec, median)),
	p25=with(experiment, tapply(ie2, codec, function(x){quantile(x)["25%"]})),
	p75=with(experiment, tapply(ie2, codec, function(x){quantile(x)["75%"]})),
	iqr=with(experiment, tapply(ie2, codec, IQR)),
	p833=with(experiment, 
		tapply(codec, codec, function(x){
			p833[p833$codec==levels(codec)[x[1]], "ie"] 
		}))
)
summarized$codec_id = rownames(summarized)

#tab = xtable(summarized[, c(7, 1, 2, 5, 6)])
tab = xtable(summarized)
caption(tab) <- "Ie values"
#colnames(tab) <- c("Codec ID", "MOS (exp)", "MOS (corr)", "IQR", "MOS (ref)")
rownames(tab) <- 1:nrow(summarized)
texfile=paste(sqe_data, "summary/p833.tex", sep="/")
print(tab, file=texfile)

