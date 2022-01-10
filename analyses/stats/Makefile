# >>>>> variables

# >>>>> recipes
.PHONY:\
	latent-mean_estimates\
	fake-data

## >>>>> abstract
latent-mean_estimates:\
	latent-mean_estimates_imageability.csv\
	latent-mean_estimates_subfreq.csv

fake-data:\
	latent-mean_fake-data.csv

## >>>>> concrete

# --args:
#  1: output file name
#  2: dataset which to analyze
latent-mean_estimates_imageability.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/latent-mean_estimates.R\
		--args\
		$@\
		d_image

# --args:
#  1: output file name
#  2: dataset which to analyze
latent-mean_estimates_subfreq.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/latent-mean_estimates.R\
		--args\
		$@\
		d_subfreq

latent-mean_model.stan: latent-mean_model-check.stan
	sed -e '/^generated quantities/,$$ d' $< > $@

latent-mean_fake-data.csv: latent-mean_fake-data-create.R
	cd ..; Rscript stats/$<
