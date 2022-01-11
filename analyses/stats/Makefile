# >>>>> variables

# >>>>> recipes
.PHONY:\
	latent-mean_estimates\
	latent-mean_fake-data_create\
	latent-mean_fake-data_check\
	reaction-time_fake-data_create

## >>>>> abstract
latent-mean_estimates:\
	latent-mean_estimates_imageability.csv\
	latent-mean_estimates_subfreq.csv

latent-mean_fake-data_create:\
	latent-mean_fake-data.csv

latent-mean_fake-data_check:\
	latent-mean_fake-data_summaries.csv

reaction-time_fake-data_create:\
	reaction-time_fake-data.csv

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
