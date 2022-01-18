# >>>>> variables

# >>>>> recipes
.PHONY:\
	latent-mean_estimates\
	latent-mean_fake-data_create\
	latent-mean_fake-data_analyse\
	reaction-time_fake-data_create\
	reaction-time_fake-data_analyse\
	reaction-time_prior-pc

## >>>>> abstract
latent-mean_estimates:\
	latent-mean_estimates_imageability.csv\
	latent-mean_estimates_subfreq.csv

latent-mean_fake-data_create:\
	latent-mean_fake-data.csv

latent-mean_fake-data_analyse:\
	latent-mean_fake-data_summaries.csv

reaction-time_fake-data_create:\
	reaction-time_fake-data.csv

reaction-time_fake-data_analyse:\
	reaction-time_fake-data_summaries.csv

reaction-time_prior-pc:\
	reaction-time_prior-pc_data.csv

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

latent-mean_fake-data.csv: latent-mean_fake-data_create.R
	cd ..; Rscript stats/$<

latent-mean_fake-data_summaries.csv: latent-mean_fake-data_analyse.R\
	latent-mean_fake-data_create
	cd ..; Rscript stats/$<

reaction-time_fake-data.csv: reaction-time_fake-data_create.R
	cd ..; Rscript stats/$<

reaction-time_fake-data_summaries.csv: reaction-time_fake-data_analyse.R\
	reaction-time_fake-data_create
	cd ..; Rscript stats/$<

reaction-time_prior-pc_data.csv: reaction-time_prior-pc_create.R\
	reaction-time_model_prior-pc.stan
	cd ..; Rscript stats/$<
