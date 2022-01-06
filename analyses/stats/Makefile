# >>>>> variables

# >>>>> recipes
.PHONY:\
	latent-mean_estimates

## >>>>> abstract
latent-mean_estimates:\
	latent-mean_estimates_imageability.csv\
	latent-mean_estimates_subfreq.csv

## >>>>> concrete
latent-mean_estimates_imageability.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/latent-mean_estimates.R\
		--args\
		# output file name
		$@\
		# dataset which to analyze
		d_image

latent-mean_estimates_subfreq.csv:\
	latent-mean_estimates.R\
	latent-mean_model.stan
	cd ..; Rscript stats/latent-mean_estimates.R\
		--args\
		# output file name
		$@\
		# dataset which to analyze
		d_subfreq
