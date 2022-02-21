# >>>>> variables
RT_ANALYSIS_PREREQ=reaction-time_analysis.R\
	reaction-time_model.stan\
	../wrangling/analysis-data_prepare.R

# >>>>> recipes
.PHONY:\
	all\
	latent-mean_estimates\
	latent-mean_fake-data_create\
	latent-mean_fake-data_analyse\
	reaction-time_prior-pc_create\
	reaction-time_analyse

all:\
	latent-mean_estimates\
	reaction-time_analyse

## >>>>> abstract
latent-mean_estimates:\
	latent-mean_estimates_imageability.csv\
	latent-mean_estimates_subfreq.csv

latent-mean_fake-data_create:\
	latent-mean_fake-data.csv

latent-mean_fake-data_analyse:\
	latent-mean_fake-data_summaries.csv

reaction-time_prior-pc_create:\
	reaction-time_prior-pc_data.csv

reaction-time_analyse:\
	reaction-time_analysis_median_draws.csv\
	reaction-time_analysis_median_loglik.RData\
	reaction-time_analysis_median_summary.csv\
	reaction-time_analysis_mean_draws.csv\
	reaction-time_analysis_mean_loglik.RData\
	reaction-time_analysis_mean_summary.csv\
	reaction-time_analysis_latent-mean_draws.csv\
	reaction-time_analysis_latent-mean_loglik.RData\
	reaction-time_analysis_latent-mean_summary.csv

## >>>>> concrete

# --args:
#  1: output file name
#  2: dataset which to analyze
latent-mean_estimates_imageability.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/$<\
		--args\
		$@\
		d_image

# --args:
#  1: output file name
#  2: dataset which to analyze
latent-mean_estimates_subfreq.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/$<\
		--args\
		$@\
		d_subfreq

latent-mean_fake-data.csv:\
	latent-mean_fake-data_create.R
	cd ..; Rscript stats/$<

latent-mean_fake-data_summaries.csv:\
	latent-mean_fake-data_analyse.R\
	latent-mean_fake-data_create
	cd ..; Rscript stats/$<

reaction-time_prior-pc_data.csv:\
	reaction-time_prior-pc_create.R\
	reaction-time_model_fake-data.stan
	cd ..; Rscript stats/$<

reaction-time_analysis_median_rt-rep.csv\
reaction-time_analysis_median_loglik.RData\
reaction-time_analysis_median_summary.csv&:\
	$(RT_ANALYSIS_PREREQ)
	cd ..; Rscript stats/$< --args median

reaction-time_analysis_mean_rt-rep.csv\
reaction-time_analysis_mean_loglik.RData\
reaction-time_analysis_mean_summary.csv&:\
	$(RT_ANALYSIS_PREREQ)
	cd ..; Rscript stats/$< --args mean

reaction-time_analysis_latent-mean_rt-rep.csv\
reaction-time_analysis_latent-mean_loglik.RData\
reaction-time_analysis_latent-mean_summary.csv&:\
	$(RT_ANALYSIS_PREREQ)
	cd ..; Rscript stats/$< --args latent_mean

../wrangling/reaction-time_analysis_colnames_rt-rep.txt:\
	reaction-time_analysis_median_draws.csv
	head -n 1 $< |\
		sed -e 's/,/\n/g' |\
		grep 'rt_rep' > $@
